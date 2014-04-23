module OptaSport
  module FetchResult
    module Basketball
      class Area < Base
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
                start_at: "#{node['date_london']} #{node['time_london']} +0000".to_datetime,
                status: node['status']
            }
          end
          matches
        end
      end

      class MatchStatistics < Base
        def read
          match = @xml_doc.css("match").first
          {
              status: match['status'],
              winner: match['winner'],
              team_a: match['team_A_name'],
              team_b: match['team_B_name'],
              fs_team_a: match['fs_A'],
              fs_team_b: match['fs_B'],
          }
        end
      end
      class Season < Base
        def all
          nodes = @xml_doc.css('competition > season')
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