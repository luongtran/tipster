# encoding: utf-8
require 'nokogiri'
module OddsFeed
  module Netbet
    CODE = 'netbet'
    ODDS_URL = "http://flux.france-pari.fr/cotes/fluxcotesnetbetsport.xml"

    # XML structure: Data > SportList > Sport > RegionList > Region > CompetitionList > Competition > MatchList > Match
    # > OfferList[Team] > Offer > Outcome

    SPORT_CODE_TO_ID = {
        'soccer' => %w(13),
        'tennis' => %w(21),
        'basketball' => %w(4),
        'rugby' => %w(38 12),
        'handball' => %w(9),
        'hockey' => %w(10),
        'football_us' => %w(7),
        'baseball' => %w(20)
    }

    class << self
      attr_accessor :local_xml_document

      # === Find all sports in the response XML
      def raw_sports
        xml_doc = self.go
        sport_nodes = xml_doc.css('Sport')
        sports = []
        sport_nodes.each do |node|
          sports << {
              id: node['id'],
              name: node['name']
          }
        end
        sports.uniq
      end

      # === Get all competitions in the response XML
      def raw_competitions
        xml_doc = self.go
        competition_nodes = xml_doc.css('Competition')
        competitions = []
        competition_nodes.each do |compt_node|
          sport_node = compt_node.ancestors('Sport').first
          competitions << {
              id: compt_node['id'],
              name: compt_node['name'],
              sport_id: sport_node['id'],
              sport_name: sport_node['name']
          }
        end
        competitions.uniq
      end

      # === Get all areas(Region) in the response XML
      def raw_areas
        xml_doc = self.go
        competition_nodes = xml_doc.css('Region')
        areas = []
        competition_nodes.each do |region_node|
          areas << {
              id: region_node['id'],
              name: region_node['name'],
          }
        end
        areas.uniq
      end

      # === Get all matches in the response XML
      def raw_matches
        xml_doc = self.go
        match_nodes = xml_doc.css('MatchList > Match')
        matches = []
        match_nodes.each do |node|
          teams = node.css('Team')
          unless teams.empty?
            competition_node = node.ancestors('Competition').first
            sport_node = node.ancestors('Sport').first
            area_node = node.ancestors('Region').first
            team_a_name = teams[0]['name']
            team_b_name = teams[1]['name']
            matches << {
                id: node['id'],
                name: "#{team_a_name} - #{team_b_name}",
                team_a_name: team_a_name,
                team_b_name: team_b_name,
                sport_id: sport_node['id'],
                start_at: self.with_time_zone(node['date']),
                sport_name: sport_node['name'],
                competition_id: competition_node['id'],
                competition_name: "#{area_node['name']} #{competition_node['name']}"
            }
          end
        end
        matches
      end

      # Clean up raw_matches and filter sports
      def recognized_matches
        log = Logger.new 'log/bookmarker_matches_feed.log'
        recognized_matches = []
        log.info "======================= Start get matches from: #{CODE.upcase}"
        raw_matches = self.raw_matches
        log.info "Total matches: #{raw_matches.count}"
        raw_matches.each do |match|
          # Do filter sport
          sport_code = SPORT_CODE_TO_ID.detect { |key, sport_ids| sport_ids.include?(match[:sport_id]) }
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

      # === Return the bet types found in the response XML
      def get_raw_bet_types
        xml_doc = self.go
        bet_nodes = xml_doc.css('Offer')
        found_bet_types = []

        bet_nodes.each do |bet_type_node|
          sport_node = bet_type_node.ancestors('Sport').first
          found_bet_types << {
              sport_name: sport_node['name'],
              sport_id: sport_node['id'],
              name: bet_type_node['type_name']
          }
        end
        found_bet_types.uniq
      end

      def fetch_odds
      end

      # === Perform search bets on the given match
      def find_odds_on_match(match, supported_bet_types)
        # Find by name of match
        # Get bet with the type if supported
        # Translate to standard code, name ...
        match_id = match.match_id

        loger = Logger.new('log/match_finder.log')
        loger.info "Start find odds for match: #{match.name}, id: #{match.match_id}"
        # === Fetch xml
        xml_doc = self.go

        result_matches = []

        # === Find bets on the found match
        found_bets = []
        bet_type_nodes = xml_doc.css("Match##{match_id} > OfferList > Offer")
        #loger.info bet_type_nodes
        # Offer node attributes example: <type_id="26088158" type_name="Over Under" number="4.5">  OMG !!!
        # Offer node attributes example: <type_id="26088130" type_name="1-N-2">

        bet_type_nodes.each do |bet_type_node|
          bet_type_support = supported_bet_types.detect { |bet_type| bet_type[CODE] == bet_type_node['type_name'] }

          if bet_type_support
            choice_nodes = bet_type_node.children
            found_choices = []
            choice_nodes.each do |choice_node|
              choice = {
                  odd: choice_node['odds']
              }
              translated_choice_name = choice_node['name']
              translated_choice_name.gsub!('Nul', 'Draw')
              translated_choice_name.gsub!('Plus', 'Over')
              translated_choice_name.gsub!('Moins', 'Under')
              translated_choice_name.gsub!('Aucune équipe', 'No Goal')

              if bet_type_node["number"].present?
                choice[:line] = bet_type_node["number"]
                choice[:selection] = "#{translated_choice_name} #{bet_type_node["number"]}"
              else
                choice[:selection] = translated_choice_name
              end

              found_choices << choice
            end
            found_bets << {
                code: bet_type_support['standard_code'],
                name: bet_type_support['standard_name'],
                choices: found_choices
            }
          end
        end
        found_bets
      end

      protected
      # === Start to feed xml
      # Return Nokogiri::Document object
      def go
        if true
          uri = URI(ODDS_URL)
          response = Net::HTTP.get_response(uri)
          doc = Nokogiri::XML(response.body)
          doc
        else
          file_name = "#{CODE}_#{Time.now.to_i}.xml"
          File.open(File.join(Rails.root, 'db', 'odds_xmls', file_name), 'w') { |f| doc.write_xml_to f }
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
        @local_xml_document ||= Nokogiri::XML File.open(File.join(Rails.root, 'db', 'odds_xmls', "france_paris.xml"))
      end

      def with_time_zone(datetime_str)
        # The time zone is Paris UTC +1
        "#{datetime_str} +0100".to_datetime
      end
    end
  end
end