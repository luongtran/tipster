#encoding: utf-8
require 'nokogiri'
module Bookmarker
  module Betclic
    CODE = 'betclic'
    ODDS_URL = 'http://xml.cdn.betclic.com/odds_en.xml'
    FR_ODDS_URL = 'http://xml.cdn.betclic.com/odds_frfr.xml'

    # Response XML structure: sports > sport > event > match > bets > bet > choice

    class << self
      # TODO: DRYing up
      def recognized_bet_types(sport = nil)
        sports_bet_types = YAML.load_file File.join(Rails.root, 'db', 'seeds', 'sports_bet_types.yml')
      end

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
      def find_bets_on_match(match)
        sport = match.sport
        bet_type_codes_filter = BET_TYPE_CODES

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
          if match.name.downcase.include?(m[:name]) || m[:name].include?(match.name.downcase)
            found_match_betclic_id = m[:betclic_match_id] # TODO: consider to save the id
            break
          end
        end

        # Start get bets on match  ==============================================
        bets_found = []
        unless found_match_betclic_id.nil?
          bet_nodes = xml_doc.css("match##{found_match_betclic_id} > bets > bet")
          bet_nodes.each do |bet|
            if bet_type_codes_filter.include?(bet['code'])
              # Get choices on current bet
              choices = bet.children
              choices_found = []
              choices.each do |choice|
                choices_found << {
                    name: choice['name'],
                    odd: choice['odd']
                }
              end
              # Save bets
              bets_found << {
                  code: bet['code'],
                  name: bet['name'],
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
        uri = URI(ODDS_URL)
        response = Net::HTTP.get_response(uri)
        # TODO: catch timeout error
        Nokogiri::XML(response.body)
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
      end
    end

  end
end