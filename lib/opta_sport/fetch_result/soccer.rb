module OptaSport
  module FetchResult
    module Soccer
      class Match < Base
        def all
          nodes = @xml_doc.css('match')
          matches = []
          nodes.each do |node|
            competition = node.ancestors('competition').first
            matches << {
                opta_match_id: node['match_id'],
                opta_competition_id: competition['competition_id'],
                name: "#{node['team_A_name']} - #{node['team_B_name']}",
                team_a: node['team_A_name'],
                team_b: node['team_B_name'],
                start_at: "#{node['date_utc']} #{node['time_utc']}".to_datetime,
                status: node['status']
            }
          end
          matches
        end
      end
      class MatchLive < Base

      end
      class MatchStatistics < Base
        attr_accessor :opta_match_id

        def initialize(xml_doc)
          @xml_doc = xml_doc
        end

        #MATCH_RESULT_ATTRS_MAP = {
        #    'status' => 'status',
        #    'winner' => 'winner',
        #    'fs_A' => 'full_time_scrore_team_A',
        #    'fs_B' => 'full_time_scrore_team_B',
        #    'hts_A' => 'half_time_scrore_team_A',
        #    'hts_B' => 'half_time_scrore_team_B',
        #    'match_period' => 'match_period'
        #}
        def read
          match = @xml_doc.css("match").first
          {
              status: match['status'],
              winner: match['winner'],
              team_a: match['team_A_name'],
              team_b: match['team_B_name'],
              fs_team_a: match['fs_A'],
              fs_team_b: match['fs_B'],
              hts_team_a: match['hts_A'],
              hts_team_b: match['hts_B']
          }
        end
      end
      class Competition < Base
        def all
          nodes = @xml_doc.css('competition')
          competitions = []
          nodes.each do |compt|
            competitions << {
                opta_competition_id: compt['competition_id'],
                opta_area_id: compt['area_id'],
                name: compt['name']
            }
          end
          competitions
        end
      end

      class Area < Base
        def all
          nodes = @xml_doc.css('area')
          areas = []
          nodes.each do |area|
            areas << {
                opta_area_id: area['area_id'],
                name: area['name'],
                country_code: area['countrycode']
                #parent_id: area.parent['area_id']
            }
          end
          areas
        end
      end

      class Season < Base
        def all
          nodes = @xml_doc.css('season')
          seasons = []
          nodes.each do |season|
            competition = season.ancestors('competition').first
            seasons << {
                opta_season_id: season['season_id'],
                opta_competition_id: competition['competition_id'],
                name: season['name'],
                start_date: season['start_date'].to_datetime,
                end_date: season['end_date'].to_datetime,
            }
          end
          seasons
        end
      end
    end
  end
end