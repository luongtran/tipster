module OptaSport
  module Fetcher
    class Hockey < Base
      AVAILABLE_FUNCTIONS = {
          #'get_areas' => {
          #    'required_params' => [],
          #    'options_params' => %w(area_id),
          #    'result_class' => OptaSport::FetchResult::Basketball::Area
          #},
          #'get_competitions' => {
          #    'required_params' => [],
          #    'options_params' => %w(area_id authorized),
          #    'result_class' => OptaSport::FetchResult::Basketball::Competition
          #},
          #'get_matches' => {
          #    'required_params' => %w(id type),
          #    'options_params' => %w(start_date end_date limit detailed last_updated),
          #    'result_class' => OptaSport::FetchResult::Basketball::Match
          #},
          #'get_seasons' => {
          #    'required_params' => %w(),
          #    'options_params' => %w(authorized coverage active id type last_updated),
          #    'result_class' => OptaSport::FetchResult::Basketball::Season
          #}
      }

      AVAILABLE_FUNCTIONS.each do |f_name, settings|
        define_method f_name do |params = {}|
          return self.go(f_name, params, settings['result_class'])
        end
      end
    end
  end
end