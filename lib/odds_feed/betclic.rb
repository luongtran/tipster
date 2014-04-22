# encoding: utf-8
require 'nokogiri'
module OddsFeed
  module Betclic
    CODE = 'betclic'
    ODDS_URL = 'http://xml.cdn.betclic.com/odds_en.xml'
    FR_ODDS_URL = 'http://xml.cdn.betclic.com/odds_frfr.xml'

    TIME_ZONE = '' # Time_london

    TEAM_NAMES_SEPERATOR = ' - '
    SPORT_CODE_TO_ID = {
        'soccer' => %(1),
        'tennis' => %(2),
        'basketball' => %(3),
        'rugby' => %(5 52), # Rugby Union and Rugby League
        'handball' => %(9),
        'hockey' => %w(13),
        'football_us' => %w(14),
        'baseball' => %w(20)
    }
    # Response XML structure: sports > sport > event > match > bets > bet > choice

    class << self

      attr_accessor :local_xml_document

      # === Find all sports in the response XML
      def raw_sports
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

      # === Get all matches in the response XML
      def raw_matches
        xml_doc = self.go
        match_nodes = xml_doc.css('match')
        matches_found = []
        match_nodes.each do |match_node|

          sport_node = match_node.ancestors('sport').first
          competition_node = match_node.ancestors('event').first

          match_name = match_node['name']

          teams = match_name.split(TEAM_NAMES_SEPERATOR)
          team_a_name, team_b_name = '', ''
          if teams.size == 2
            team_a_name = teams.first
            team_b_name = teams.last
            matches_found << {
                id: match_node['id'],
                name: match_name,
                team_a_name: team_a_name,
                team_b_name: team_b_name,
                start_at: match_node['start_date'].to_datetime,
                sport_id: sport_node['id'],
                sport_name: sport_node['name'],
                competition_id: competition_node['id'],
                competition_name: competition_node['name']
            }
          end
        end
        matches_found
      end

      # Clean up raw matches and filter sports
      def recognized_matches
        log = Logger.new 'log/bookmarker_matches_feed.log'
        recognized_matches = []
        log.info "======================= Start get matches from: #{CODE.upcase}"
        raw_matches = self.raw_matches
        log.info "Total matches: #{raw_matches.count}"
        raw_matches.each do |match|
          # Do filter sport
          sport_code = SPORT_CODE_TO_ID.detect { |key, sport_ids| sport_ids.include? match[:sport_id] }
          sport_code = sport_code.first if sport_code
          if sport_code
            # Do filter bet types
            recognized_matches << {
                match_id: match[:id],
                name: match[:name],
                sport_code: sport_code,
                start_at: match[:start_at],
                team_a_name: match[:team_a_name],
                team_b_name: match[:team_b_name],
                competition_id: match[:competition_id],
                competition_name: match[:competition_name],
            }
          end
        end
        log.info "Recognized matches: #{recognized_matches.count}"
        log.info "============================================================="
        recognized_matches
      end

      # === Get all competitions(events) in the response XML
      def raw_competitions
        xml_doc = self.go
        competition_nodes = xml_doc.css('event')
        competitions_found = []
        competition_nodes.each do |event_node|
          sport_node = event_node.ancestors('sport').first
          competitions_found << {
              id: event_node['id'],
              name: event_node['name'],
              sport_id: sport_node['id']
          }
        end
        competitions_found
      end

      # === Translate name bet type of from Betclic to our site
      def translate_bet_type(bet_type)
      end

      # === Return the bet types found in the response XML
      def raw_bet_types
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

      # === Perform search bets on the given match
      def find_odds_on_match(match, supported_bet_types)
        target_match_id = match.match_id
        xml_doc = self.go
        # Start get bets on match  ==============================================
        bet_nodes = xml_doc.css("match##{target_match_id} > bets > bet")

        bets_found = []
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
        bets_found
      end

      protected
      # Start to feed xml
      # Return Nokogiri::Document object
      def go
        if false
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
