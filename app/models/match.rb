# == Schema Information
#
# Table name: matches
#
#  id                 :integer          not null, primary key
#  match_id           :string(255)
#  sport_id           :integer
#  name               :string(255)
#  en_name            :string(255)
#  fr_name            :string(255)
#  betclic_match_id   :string(255)
#  betclic_event_id   :string(255)
#  start_at           :datetime
#  status             :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  competition_id     :string(255)
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
  belongs_to :competition, foreign_key: :competition_id

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :match_id, uniqueness: true
  validates_uniqueness_of :betclic_match_id, allow_blank: true

  # ==============================================================================
  # SCOPE
  # ==============================================================================
  scope :betable, -> { where(status: STATUS_FIXTURE) }

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def prepare_matches_today
    end

    def update_matches
      # http://api.core.optasports.com/soccer/get_matches?type=season&id=8318&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      # Get matches by active seasons, limit 7 days
      matches = []
      # Load active seasons

      from_date = DateTime.now
      to_date = from_date + DAY_INTERVAL.days
      seasons = Season.all
      seasons.each do |season|
        %w(football tennis basketball).each do |sport|
          fetcher = OptaSport::Fetcher.send(sport)
          if fetcher.respond_to?(:get_matches)
            res = fetcher.get_matches(
                id: season.season_id,
                type: 'season',
                start_date: from_date,
                end_date: to_date
            )
            if fetcher.success?
              matches += res.all
            else
              puts "Error: #{res.message}; \n URL: #{fetcher.last_url}"
            end
          end

        end
      end
      matches
      matches.each do |match|
        Match.create(match)
      end
    end

    def update_seasons
      # http://api.core.optasports.com/soccer/get_seasons?authorized=yes&active=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      seasons = []
      %w(football tennis basketball).each do |sport|
        fetcher = OptaSport::Fetcher.send(sport)
        if fetcher.respond_to?(:get_seasons)
          res = fetcher.get_seasons(
              authorized: 'yes',
              active: 'yes'
          )
          if fetcher.success?
            seasons += res.all
          end
        end
      end
      seasons.each do |season|
        Season.create(season)
      end
    end

    def update_competitions
      # http://api.core.optasports.com/soccer/get_competitions?authorized=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      competitions = []
      %w(football tennis basketball).each do |sport|
        fetcher = OptaSport::Fetcher.send(sport)
        if fetcher.respond_to?(:get_competitions)
          res = fetcher.get_competitions(
              authorized: 'yes'
          )
          if fetcher.success?
            competitions += res.all
          end
        end

      end
      competitions.each do |competition|
        Competition.create(competition)
      end
    end
  end
end
