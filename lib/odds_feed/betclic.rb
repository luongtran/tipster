# encoding: utf-8
require 'nokogiri'
module OddsFeed
  module Betclic
    CODE = 'betclic'
    ODDS_URL = 'http://xml.cdn.betclic.com/odds_en.xml'
    FR_ODDS_URL = 'http://xml.cdn.betclic.com/odds_frfr.xml'

    SPORT_CODE_TO_ID = {
        #'<sport_code>' => '<ID attribute of a "sport" tag in the response XML document>'
        'soccer' => 1,
        'tennis' => 2,
        'basketball' => 3,
        'rugby' => 5,
        'handball' => 9,
        'hockey' => 13,
        'football_us' => 14,
        'baseball' => 20
    }
    # Response XML structure: sports > sport > event > match > bets > bet > choice

    class << self

      attr_accessor :local_xml_document
      # === Translate name bet type of from Betclic to our site
      def translate_bet_type(bet_type)
      end

      # === Return the bet types found in the response XML
      def get_raw_bet_types
        xml_doc = self.go
        bet_nodes = xml_doc.css('bet')
        found_bet_types = []

        bet_nodes.each do |bet_node|
          sport_node = bet_node.ancestors('sport').first
          found_bet_types << {
              name: bet_node['name'],
              code: bet_node['code'],
              sport_id: sport_node['id'],
              sport_name: sport_node['name']
          }
        end
        found_bet_types.uniq
      end

      def fetch_odds(lang = 'en')
        xml_doc = self.go
        match_nodes = xml_doc.css('sport > event > match')
        result_matches = []
        match_nodes.each do |node|
          result_matches << {
              name: node['name'],
              betclic_match_id: node['id'],
              start_date: node['start_date'],
          }
        end
        result_matches
      end

      # === Perform search bets on the given match
      def find_odds_on_match(target_match)
        sport_code = target_match.sport_code
        supported_bet_types = BetType.recognized_bet_types(CODE, sport_code)
        xml_doc = self.go
        match_nodes = xml_doc.css('sport > event > match')

        # Start find match by name ==============================================
        result_matches = []
        match_nodes.each do |node|
          result_matches << {
              name: node['name'].downcase,
              betclic_match_id: node['id'],
              start_date: node['start_date'],
          }
        end

        found_match_betclic_id = nil
        result_matches.each do |m|
          if target_match.name.downcase.include?(m[:name]) || m[:name].include?(target_match.name.downcase)
            found_match_betclic_id = m[:betclic_match_id] # TODO: consider to save the id
            break
          end
        end

        # Start get bets on match  ==============================================
        bets_found = []
        unless found_match_betclic_id.nil?
          bet_nodes = xml_doc.css("match##{found_match_betclic_id} > bets > bet")
          bet_nodes.each do |bet|
            bet_type_support = supported_bet_types.detect { |bet_type| bet_type[CODE] == bet['code'] }

            if bet_type_support
              # Get choices on current bet
              choice_nodes = bet.children
              choices_found = []
              choice_nodes.each do |choice_node|
                choice = {
                    odd: choice_node['odd']
                }
                if bet_type_support['has_line']
                  choice[:line] = choice_node['name'].split(' ').last
                  choice[:selection] = choice_node['name'].gsub(choice[:line], '')
                else
                  choice[:selection] = choice_node['name']
                end

                choices_found << choice
              end
              # Save bets
              bets_found << {
                  code: bet_type_support['standard_code'],
                  name: bet_type_support['standard_name'],
                  choices: choices_found
              }
            end
          end
        end
        bets_found
      end

      # === Find all sports in the response XML
      def support_sports
        xml_doc = self.go
        sport_nodes = xml_doc.css('sport')
        re_sports = []
        sport_nodes.each do |node|
          re_sports << {
              name: node['name'],
              id: node['id']
          }
        end
        re_sports
      end

      protected
      # Start to feed xml
      # Return Nokogiri::Document object
      def go
        if true
          uri = URI(ODDS_URL)
          response = Net::HTTP.get_response(uri)
          # TODO: catch timeout error
          Nokogiri::XML(response.body)
        else
          read_from_local
        end
      end

      # === Save to xml file for use later
      # Run on seperate thread
      def save_to_local(doc)
        # Create lock file
        file_name = "#{CODE}#{Time.now.to_i}.xml"
        File.open(File.join(Rails.root, db, 'odds_xmls', file_name), 'w') do |f|
          doc.write_xml_to f
        end
        # Remove lock file
      end

      # === Read lastest xml file for use
      # Called when the lastest file is not experied
      def read_from_local
        @local_xml_document ||= Nokogiri::XML File.open(File.join(Rails.root, 'db', 'odds_xmls', "odds_en.xml"))
      end
    end
  end
end
