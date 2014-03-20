# == Schema Information
#
# Table name: matches
#
#  id                  :integer          not null, primary key
#  opta_competition_id :string(255)
#  opta_match_id       :string(255)
#  betclic_match_id    :string(255)
#  betclic_event_id    :string(255)
#  sport_id            :integer
#  team_a              :string(255)
#  team_b              :string(255)
#  name                :string(255)
#  en_name             :string(255)
#  fr_name             :string(255)
#  start_at            :datetime
#  status              :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class Match < ActiveRecord::Base
  DAY_INTERVAL = 7

  STATUS_PLAYING = 'Playing' # Match is still playing (live)
  STATUS_FIXTURE = 'Fixture' # Match has not yet started
  STATUS_POSTPONED = 'Postponed' # Match is postponed (status will change to Fixture once it's rescheduled)
  STATUS_SUSPENDED = 'Suspended' # Match is suspended during the match and can be resumed again
  STATUS_PLAYED = 'Played' # Match has been played
  STATUS_CANCELLED = 'Cancelled' # Match is cancelled and won't be played again

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :competition, foreign_key: :opta_competition_id, primary_key: :opta_competition_id

  belongs_to :sport
  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :opta_match_id, uniqueness: true
  validates_uniqueness_of :betclic_match_id, allow_blank: true

  # ==============================================================================
  # SCOPE
  # ==============================================================================
  scope :betable, -> { where(status: STATUS_FIXTURE) }

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self

    def load_data(params, relation = self)
      if params[:sport_id].present?
        relation = relation.where(sport_id: params[:sport_id])
      end
      if params[:competition_id].present?
        relation = relation.where(opta_competition_id: params[:competition_id])
      end
      relation.includes(:competition, :sport)
    end


    def get_bets_on_match(match)
      Betclic.find_bets_on_match(match)
    end

    # TODO: after getmatches, try to find id on odds feed from betclic
    def update_matches
      # http://api.core.optasports.com/soccer/get_matches?type=season&id=8318&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      # Get matches on active seasons
      sports = Sport.where(name: %w(football basketball))
      # Load active seasons

      from_date = DateTime.now
      to_date = from_date + DAY_INTERVAL.days
      seasons = Season.all

      seasons.each do |season|
        sports.each do |sport|
          fetcher = OptaSport::Fetcher.send(sport.name)
          if fetcher.respond_to?(:get_matches)
            res = fetcher.get_matches(
                id: season.opta_season_id,
                type: 'season',
                start_date: from_date,
                end_date: to_date
            )
            if fetcher.success?
              matches = res.all
              matches.each do |match|
                Match.create(match.merge(sport_id: sport.id))
              end
            else
              puts "Error: #{res.message}; \n URL: #{fetcher.last_url}"
            end
          end
        end
      end

    end

    def update_seasons
      # http://api.core.optasports.com/soccer/get_seasons?authorized=yes&active=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      sports = Sport.where(name: %w(football basketball))

      sports.each do |sport|
        fetcher = OptaSport::Fetcher.send(sport.name)
        if fetcher.respond_to?(:get_seasons)
          res = fetcher.get_seasons(
              authorized: 'yes',
              active: 'yes'
          )
          if fetcher.success?
            seasons = res.all
            seasons.each do |season|
              Season.create(season)
            end
          end
        end
      end

    end

    def update_competitions
      # http://api.core.optasports.com/soccer/get_competitions?authorized=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      sports = Sport.where(name: %w(football basketball))
      compts = []
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.send(sport.name)
        if fetcher.respond_to?(:get_competitions)
          res = fetcher.get_competitions(
              authorized: 'yes'
          )
          if fetcher.success?
            competitions = res.all
            compts += competitions
            competitions.each do |competition|
              Competition.create(competition)
            end
          else
            puts "Error: #{res.message}; \n URL: #{fetcher.last_url}"
          end
        end

      end
      compts
    end

  end

  def teams
    self.name.split('vs')
  end

  def start_date
    self.start_at.to_date
  end
end
