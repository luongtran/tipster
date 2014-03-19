require 'nokogiri'
module Betclic
  EN_ODDS_URL = 'http://xml.cdn.betclic.com/odds_en.xml'
  FR_ODDS_URL = 'http://xml.cdn.betclic.com/odds_frfr.xml'
  class Fetcher
  end
  class << self
    def fetch_odds(lang = 'en')
      if lang == 'fr'
        uri = URI(FR_ODDS_URL)
      else
        uri = URI(EN_ODDS_URL)
      end
      response = Net::HTTP.get_response(uri)
      xml_doc = Nokogiri::XML(response.body)
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
    end


    # sport param must be id of sport on betclic
    def find_matches_by_sport(sport)
      # football = 1
    end
  end

end