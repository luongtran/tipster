require 'nokogiri'
module Betclic
  EN_ODDS_URL = 'http://xml.cdn.betclic.com/odds_en.xml'
  FR_ODDS_URL = 'http://xml.cdn.betclic.com/odds_frfr.xml'
  class Fetcher
  end
  class << self
    # Start feed xml and return Nokogiri::Document object
    def go
      uri = URI(EN_ODDS_URL)
      response = Net::HTTP.get_response(uri)
      Nokogiri::XML(response.body)
    end

    def fetch_odds(lang = 'en')
      xml_doc = self.go
      match_nodes = xml_doc.css('sport > event > match')
      result_matches = []
      match_nodes.each do |node|
        # a match tag attributes in example:
        # name="Brazil - Croatia"
        # id="656485"
        # start_date="2014-06-12T21:00:00"
        # live_id=""
        # streaming="0"
        result_matches << {
            name: node['name'],
            betclic_match_id: node['id'],
            start_date: node['start_date'],
        }
      end
      result_matches
    end


    # sport param must be id of sport on betclic
    def find_matches_by_sport(sport)
      # football = 1
    end

    def find_bets_on_match(match)

      # TODO: do follow these steps for better performance:
      # 1. filter by sport
      # 2. filter by event id, it's competition on the local db
      # 3. find with name
      xml_doc = self.go
      match_nodes = xml_doc.css('sport > event > match')
      result_matches = []
      match_nodes.each do |node|
        result_matches << {
            name: node['name'].downcase,
            betclic_match_id: node['id'],
            start_date: node['start_date'],
        }
      end
      betclic_id_match = nil
      result_matches.each do |m|
        if match.name.downcase.include?(m[:name]) || m[:name].include?(match.name.downcase)
          betclic_id_match = m[:betclic_match_id]

          # TODO: update betclic_match_id for match
          break
        end
      end
      match_found = nil
      bets_found = []
      unless betclic_id_match.nil?
        bet_nodes = xml_doc.css("match##{betclic_id_match} > bets > bet")
        bet_nodes.each do |bet|
          choices = bet.children
          choices_found = []
          choices.each do |choice|
            choices_found << {
                name: choice['name'],
                odd: choice['odd']
            }
          end

          bets_found << {
              code: bet['code'],
              name: bet['name'],
              choices: choices_found
          }
        end
      end
      bets_found
    end

    # Find all available sports on betclic
    def support_sports
      xml_doc = self.go
      sport_nodes = xml_doc.css('sport')

      sport_nodes.each do |node|

      end

    end
  end

end