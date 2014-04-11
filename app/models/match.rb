# == Schema Information
#
# Table name: matches
#
#  id                  :integer          not null, primary key
#  opta_match_id       :integer          not null
#  sport_code          :string(255)      not null
#  opta_competition_id :integer
#  team_a              :string(255)
#  team_b              :string(255)
#  name                :string(255)
#  start_at            :datetime         not null
#  status              :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class Match < ActiveRecord::Base
  TEAM_NAMES_SEPERATOR = '-'

  STATUS_PLAYING = 'Playing' # Match is still playing (live)
  STATUS_FIXTURE = 'Fixture' # Match has not yet started
  STATUS_POSTPONED = 'Postponed' # Match is postponed (status will change to Fixture once it's rescheduled)
  STATUS_SUSPENDED = 'Suspended' # Match is suspended during the match and can be resumed again
  STATUS_PLAYED = 'Played' # Match has been played
  STATUS_CANCELLED = 'Cancelled' # Match is cancelled and won't be played again

  MAXIMUM_DAYS_FROM_NOW = 7
  MIN_TIME_BEFORE_MATCH_START = 1.hours

  attr_accessor :result

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :competition, foreign_key: :opta_competition_id, primary_key: :opta_competition_id

  belongs_to :sport, foreign_key: :sport_code, primary_key: :code
  has_many :tips, foreign_key: :match_id, primary_key: :opta_match_id
  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :opta_match_id, uniqueness: true

  # ==============================================================================
  # SCOPE
  # ==============================================================================
  scope :betable, -> { where(status: STATUS_FIXTURE) }

  delegate :name, to: :competition, prefix: true
  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self

    def load_data(params = {}, relation = self)
      if params[:sport].present?
        relation = relation.perform_sport_param(params[:sport])
      end

      if params[:competition].present?
        relation = relation.where(opta_competition_id: params[:competition])
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

      relation.includes(:sport, :competition => [:area]).order('start_at asc')
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
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def to_param
    "#{self.opta_match_id}-#{self.team_a}-vs-#{self.team_b}".parameterize
  end

  def to_s
    "#{self.opta_match_id}-#{self.team_a}-#{self.team_b}"
  end

  def teams
    self.name.split(TEAM_NAMES_SEPERATOR)
  end

  def start_date
    self.start_at.to_date
  end

  # Update status + start_at
  def update_info

  end

  # Return a MatchResult object
  def preload_result
    fetcher = OptaSport::Fetcher.find_fetcher_for(self.sport_code)
    if fetcher
      @result = MatchResult.new(fetcher.get_match_details(self.opta_match_id).read)
    end
  end

  # Find bets and odds from the given bookmarker
  def find_bets(bookmarker)
    bets = {}
    %w(betclic france_paris).each do |bookmarker_code|
      bets[bookmarker_code] = Bookmarker.find_odds_feed_module_by(bookmarker_code).find_odds_on_match(self)
    end
    bets
  end
end
