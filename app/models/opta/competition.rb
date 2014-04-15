class Opta::Competition < ActiveRecord::Base
  belongs_to :area, class_name: Opta::Area, foreign_key: :opta_area_id, primary_key: :opta_area_id
  belongs_to :sport, foreign_key: :sport_code, primary_key: :code

  validates_uniqueness_of :opta_competition_id, scope: :sport_code

  class << self
    def initialize_data
      # http://api.core.optasports.com/soccer/get_competitions?authorized=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      sports = Sport.where(code: OptaSport::AVAILABLE_SPORT)
      compts = []
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.find_fetcher_for(sport.code)
        if fetcher.respond_to?(:get_competitions)
          res = fetcher.get_competitions(authorized: true)
          if fetcher.success?
            competitions = res.all
            compts += competitions
            competitions.each do |competition|
              create competition.merge(sport_code: sport.code)
            end
          else
            puts fetcher.error.log_format
          end
        end
      end
      compts
    end
  end

  #def to_param
  #  self.name.parameterize('_') + '-'+ self.opta_area_id.to_s
  #end
end
