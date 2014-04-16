class Match < ActiveRecord::Base
  TEAM_NAMES_SEPERATOR = '-'
  MAXIMUM_DAYS_FROM_NOW = 7
  MIN_TIME_BEFORE_MATCH_START = 1.hours

  attr_accessor :result

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :competition, foreign_key: :competition_uid, primary_key: :uid
  belongs_to :sport, foreign_key: :sport_code, primary_key: :code

  has_many :tips, foreign_key: :match_uid, primary_key: :uid
  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates_presence_of :competition_uid, :sport_code
  validates_uniqueness_of :uid

  delegate :name, to: :competition, prefix: true
  delegate :name, to: :sport, prefix: true
  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self

    def load_data(params = {}, relation = self)
      if params[:sport].present?
        relation = relation.perform_sport_param(params[:sport])
      end

      if params[:competition].present?
        relation = relation.where(competition_uid: params[:competition])
      end

      if params[:min_date].present?
        # FIXME: how to use start_at as symbol here?
        relation = relation.where("start_at >= ?", params[:min_date].to_date)
      end

      if params[:max_date].present?
        relation = relation.where("start_at <= ?", params[:max_date].to_date)
      end

      if params[:on_date].present?
        relation = relation.perform_date_param(params[:on_date])
      end
      # Search in name of match
      if params[:search].present?
        relation = relation.where('name like ?', "%#{params[:search]}%")
      end

      relation.includes(:sport, :competition).order('start_at asc')
    end

    def available_to_create_tips(params)
      # Add start and max date to limit
      load_data(
          params.merge(
              if params[:on_date].present?
                {
                    on_date: params[:on_date].to_date
                }
              else
                {
                    min_date: Date.today,
                    max_date: Date.today + MAXIMUM_DAYS_FROM_NOW
                }
              end
          )
      )
    end

    def available_on_bookmarkers

    end

    def perform_sport_param(sport, relation = self)
      relation.where(sport_code: sport)
    end

    # Find match with the start time in the given date
    def perform_date_param(date, relation = self)
      date = date.to_date
      if date <= Date.today
        start_from = DateTime.now + MIN_TIME_BEFORE_MATCH_START
      else
        start_from = date.beginning_of_day
      end
      relation = relation.where(start_at: start_from..date.end_of_day)
      relation
    end

    def fetch_from_betclic
      raw_matches = OddsFeed::Betclic.raw_matches
      raw_matches.each do |raw_match|
        # Ignore bets on outright winner of competition
        if raw_match[:name].include? TEAM_NAMES_SEPERATOR
          teams = raw_match[:name].split TEAM_NAMES_SEPERATOR
          # Find sport code corresponding to sport_id in Betclic
          sport_code = Sport::CODE_TO_BETCLIC_SPORT_ID.key raw_match[:sport_id].to_i
          if sport_code
            create(
                uid: raw_match[:id],
                name: raw_match[:name],
                team_a: teams.first,
                team_b: teams.last,
                start_at: raw_match[:start_date],
                competition_uid: raw_match[:event_id],
                sport_code: sport_code,
            )
          end
        end
      end
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def to_param
    "#{self.uid}-#{self.team_a}-vs-#{self.team_b}".parameterize
  end

  def to_s
    "#{self.uid}-#{self.team_a}-vs-#{self.team_b}"
  end

  def start_date
    self.start_at.to_date
  end

  # Find bets and odds from the given bookmarker
  def find_bets
    raise 'Luan HT'
  end
end
