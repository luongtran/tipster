#encoding: utf-8
module Bookmarker
  module FranceParis
    CODE = 'france_paris'
    BET_TYPES_MAP = {
        '1-2' => 'Match Winner',
        '1-N-2' => 'Match Result',
        'Over Under' => 'Over/Under',
        '1ère équipe à marquer' => 'First Team Score'
    }
    HAS_LINE_BET_TYPES = ['Over Under']

    # Translate bet type names ========================
    # 1-2                     Match winner
    # Mi-temps avec le +      Half-time
    # 1ère équipe à marquer   First team score
    # 1-N-2                   Match result; Three ways; 1X2
    # =================================================

    EXPIRED_IN = 5.minutes
    ODDS_URL = "http://flux.france-pari.fr/cotes/fluxcotesnetbetsport.xml"

    # XML structure: Data > SportList > Sport > RegionList > Region > CompetitionList > Competition > MatchList > Match
    # > OfferList[Team] > Offer > Outcome

    class << self
      def fetch_odds
        xml_doc = self.go
        match_nodes = xml_doc.css('MatchList > Match')
        result_matches = []
        #found = []
        match_nodes.each do |node|
          teams = node.css('Team')
          unless teams.empty?
            team_a_name = teams[0]['name']
            team_b_name = teams[1]['name']
            result_matches << {
                name: "#{team_a_name} vs #{team_b_name}",
                team_a: team_a_name,
                team_b: team_b_name,
                france_paris_match_id: node['id'],
                start_date: node['date'],
            }
          end
        end
        result_matches
      end

      def find_bets_on_match(match)
        loger = Logger.new('log/match_finder.log')
        # === Fetch xml
        xml_doc = self.go

        # === Parser xml
        match_nodes = xml_doc.css('MatchList > Match')
        result_matches = []

        # === Find match by team names
        found_math_id = nil
        match_nodes.each do |node|
          teams = node.css('Team')
          unless teams.empty?
            team_a_name = teams[0]['name']
            team_b_name = teams[1]['name']
            # TODO: the current filter method is very simple. try to make it more effective
            if match.name.downcase.include?(team_a_name.downcase) && match.name.downcase.include?(team_b_name.downcase)
              # Bingooo!
              found_math_id = node['id']
              break
            end
          end
        end

        # === Find bets on the found match
        found_bets = []
        if found_math_id
          bet_type_nodes = xml_doc.css("Match##{found_math_id} > OfferList > Offer")
          #loger.info bet_type_nodes
          # Offer node attributes example: <type_id="26088158" type_name="Over Under" number="4.5">  OMG !!!
          # Offer node attributes example: <type_id="26088130" type_name="1-N-2">

          bet_type_nodes.each do |bet_type_node|
            translated_bet_type_name = BET_TYPES_MAP[bet_type_node['type_name']]

            choice_nodes = bet_type_node.children
            found_choices = []
            choice_nodes.each do |choice_node|

              if translated_bet_type_name
                translated_choice_name = choice_node['name']
                if HAS_LINE_BET_TYPES.include?(bet_type_node['type_name'])
                  translated_choice_name += " #{bet_type_node["number"]}"
                end

                found_choices << {
                    name: translated_choice_name,
                    odd: choice_node['odds']
                }
              end
            end
            found_bets << {
                name: translated_bet_type_name,
                number: bet_type_node['number'],
                choices: found_choices
            }
          end
        end
        found_bets
      end

      protected
      def go
        uri = URI(ODDS_URL)
        response = Net::HTTP.get_response(uri)
        doc = Nokogiri::XML(response.body)
        file_name = "#{CODE}_#{Time.now.to_i}.xml"
        File.open(File.join(Rails.root, 'db', 'odds_xmls', file_name), 'w') { |f| doc.write_xml_to f }
        doc
      end

      def save_to_local
        # Create lock file
        file_name = "#{CODE}#{Time.now.to_i}.xml"
        File.open(File.join(Rails.root, db, 'odds_xmls', file_name), 'w') do |f|
          doc.write_xml_to f
        end

        # Remove lock file
      end

      def read_from_local

      end

      def local_file_expired?
        # Load file and compare to expired or not
        EXPIRED_IN
      end
    end
  end
end