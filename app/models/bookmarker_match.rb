class BookmarkerMatch < ActiveRecord::Base
  MIN_TIME_BEFORE_MATCH_START = 30.minutes
  MAXIMUM_DAYS_FROM_NOW = 60

  belongs_to :bookmarker, foreign_key: :bookmarker_code, primary_key: :code

  belongs_to :sport, foreign_key: :sport_code, primary_key: :code

  validates_presence_of :bookmarker_code, :sport_code, :match_id, :name, :start_at, :competition_name, :competition_id
  validates_uniqueness_of :match_id, scope: :bookmarker_code

  class << self
    def load_data(params = {}, relation = self)
      if params[:sport].present?
        relation = relation.perform_sport_param(params[:sport])
      end
      if params[:bookmarker].present?
        relation = relation.perform_bookmarker_param(params[:bookmarker])
      end

      if params[:search].present?
        relation = relation.perform_search_param(params[:search])
      end

      relation.includes(:sport, :bookmarker)
    end

    def betable(params = {})
      where(start_at: (DateTime.now + MIN_TIME_BEFORE_MATCH_START)..MAXIMUM_DAYS_FROM_NOW.days.from_now).
          load_data(params)
    end

    def perform_sport_param(sport, relation = self)
      relation.where(sport_code: sport)
    end

    def perform_bookmarker_param(bookmarker_code, relation = self)
      relation.where(bookmarker_code: bookmarker_code)
    end

    def perform_search_param(search, relation = self)
      relation.where('name like ?', "%#{search}%")
    end
  end

  def to_param
    "#{self.match_id}-#{self.name}".parameterize
  end

  def find_odds
    odd_feeder = Bookmarker.find_odds_feed_module_by self.bookmarker_code
    if odd_feeder
      # TODO: Pending here!
    else
      []
    end
  end

  def start_date
    self.start_at.to_date
  end
end
