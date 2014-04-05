# encoding: utf-8
require 'nokogiri'
module FranceParis

  CODE = 'france_paris'
  ODDS_URL = "http://flux.france-pari.fr/cotes/fluxcotesnetbetsport.xml"

  # XML structure: Data > SportList > Sport > RegionList > Region > CompetitionList > Competition > MatchList > Match
  # > OfferList[Team] > Offer > Outcome

  class << self
    attr_accessor :local_xml_document

    # === Translate name bet type of from FranceParis to our site
    def translate_bet_type(bet_type)
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

    # === Perform search bets on the given match
    def find_bets_on_match(match)
      # Find by name of match
      # Get bet with the type if supported
      # Translate to standard code, name ...

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
      supported_bet_types = BetType.recognized_bet_types(CODE, match.sport.code)
      # === Find bets on the found match
      found_bets = []
      if found_math_id
        bet_type_nodes = xml_doc.css("Match##{found_math_id} > OfferList > Offer")
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

              if bet_type_support['has_line']
                choice[:selection] = "#{choice_node['name']} #{bet_type_node["number"]}"
              else
                choice[:selection] = choice_node['name']
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


      end
      found_bets
    end

    # === Find all sports in the response XML
    def support_sports
      xml_doc = self.go
      sport_nodes = xml_doc.css('Sport')
      found_sports = []
      sport_nodes.each do |node|
        found_sports << {
            name: node['name'],
            id: node['id']
        }
      end
      found_sports.uniq
    end

    protected
    # === Start to feed xml
    # Return Nokogiri::Document object
    def go
      #uri = URI(ODDS_URL)
      #response = Net::HTTP.get_response(uri)
      #doc = Nokogiri::XML(response.body)
      #file_name = "#{CODE}_#{Time.now.to_i}.xml"
      #File.open(File.join(Rails.root, 'db', 'odds_xmls', file_name), 'w') { |f| doc.write_xml_to f }
      #doc
      read_from_local
    end

    # === Save to xml file for use later
    # Run on seperate thread
    # TODO: DRYing up with Betclic module
    def save_to_local(doc)
      # Create lock file
      file_name = "#{CODE}#{Time.now.to_i}.xml"
      File.open(File.join(Rails.root, db, 'odds_xmls', file_name), 'w') do |f|
        doc.write_xml_to f
      end
      # Remove lock file
    end

    def read_from_local
      @local_xml_document ||= Nokogiri::XML File.open(File.join(Rails.root, 'db', 'odds_xmls', "france_paris.xml"))
    end
  end
end
