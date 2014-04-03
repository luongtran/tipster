module Bookmarker
  require 'nokogiri'
  module Betclic
    CODE = 'betclic'
    EN_ODDS_URL = 'http://xml.cdn.betclic.com/odds_en.xml'
    FR_ODDS_URL = 'http://xml.cdn.betclic.com/odds_frfr.xml'

    # Response XML structure: sports > sport > event > match > bets > bet > choice

    class << self
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

      # Sport param must be id of sport on betclic
      def find_matches_by_sport(sport)
      end

      def find_bets_on_match(match)
        sport = match.sport
        bet_type_codes_filter = sport.bet_types.on_betclic.pluck(:betclic_code)

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

      # Find all available sports on betclic
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

      def bet_types
        xml_doc = self.go
        bet_nodes = xml_doc.css('bet')
        re_bet_types = []
        bet_nodes.each do |bet|
          sport = bet.parent.parent.parent.parent
          re_bet_types << {
              name: bet['name'],
              code: bet['code'],
              sport_id: sport['id'],
              sport_name: sport['name']
          }
        end
        re_bet_types.uniq
      end

      protected
      # Start to feed xml
      # Return Nokogiri::Document object
      def go
        uri = URI(EN_ODDS_URL)
        response = Net::HTTP.get_response(uri)
        # TODO: catch timeout error
        Nokogiri::XML(response.body)
      end
    end

  end
end