# ======================================================================
# Tennis Result Classes
# ======================================================================

require 'opta_sport/fetch_result/base'
module OptaSport
  module FetchResult
    module Tennis
      class Season < Base
        def all
          nodes = @xml_doc.css('competition > season')
          seasons = []
          nodes.each do |season|
            if season['end_date'].to_datetime > Date.today
              competition = season.parent
              seasons << {
                  opta_season_id: season['season_id'],
                  opta_competition_id: competition['competition_id'],
                  name: season['name'],
                  start_date: season['start_date'].to_datetime,
                  end_date: season['end_date'].to_datetime,
              }
            end
          end
          seasons
        end
      end
      class Competition < Base
      end
      class Match < Base
      end
    end
  end
end