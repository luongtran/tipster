module OptaSport
  module Fetcher
    class Soccer < Base
      AVAILABLE_FUNCTIONS = {
          'get_areas' => {
              'required_params' => [],
              'options_params' => %w(area_id),
              'result_class' => OptaSport::FetchResult::Soccer::Area
          },
          'get_match_statistics_v2' => {
              'required_params' => %w(id),
              'options_params' => [],
              'result_class' => OptaSport::FetchResult::Soccer::MatchStatistics
          },
          'get_competitions' => {
              'required_params' => [],
              'options_params' => %w(area_id authorized),
              'result_class' => OptaSport::FetchResult::Soccer::Competition
          },
          'get_matches' => {
              'required_params' => %w(id type),
              'options_params' => %w(start_date end_date limit detailed last_updated),
              'result_class' => OptaSport::FetchResult::Soccer::Match
          },
          'get_matches_live' => {
              'required_params' => [],
              'options_params' => %w(id now_playing date minutes detailed type),
              'result_class' => OptaSport::FetchResult::Soccer::MatchLive
          },
          'get_seasons' => {
              'required_params' => %w(),
              'options_params' => %w(authorized coverage active id type last_updated),
              'result_class' => OptaSport::FetchResult::Soccer::Season
          }
      }
      AVAILABLE_FUNCTIONS.each do |f_name, infor|
        define_method f_name do |params = {}|
          return self.go(f_name, params, infor['result_class'])
        end
      end

      def get_match_details(opta_match_id)
        params = {
            id: opta_match_id,
            type: 'match',
            detailed: true
        }
        self.go('get_matches', params, OptaSport::FetchResult::Soccer::MatchStatistics)
      end

    end
  end
end