module OptaSport
  module MatchResult
    class Base
      attr_accessor :xml_doc, :opta_match_id

      def initialize(xml_doc)
        @xml_doc = xml_doc
      end
    end

    module Soccer
      class SoccerMatchStatistics
        #def initialize(xml_doc)
        #  super
        #end
        MATCH_RESULT_ATTRS_MAP = {
            'winner' => 'winner',
            'fs_A' => 'full_time_scrore_team_A',
            'fs_B' => 'full_time_scrore_team_B',
            'hts_A' => 'half_time_scrore_team_A',
            'hts_B' => 'half_time_scrore_team_B',
            'match_period' => 'match_period'
        }

        def read
          # TODO: in-progress
          match = @xml_doc.css("match[match_id='1662517']").first
          {
              winner: match['winner'],
              fs_team_a: match['fs_A'],
              fs_team_b: match['fs_B'],
              hts_team_a: match['hts_A'],
              hts_team_b: match['hts_B']
          }
        end
      end
    end

    class Tennis
    end
    class Basketball
    end
  end
end