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
  TEAM_NAMES_SEPERATOR = '-'

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

    def load_data(params = {}, relation = self)
      if params[:sport_id].present?
        relation = relation.where(sport_id: params[:sport_id])
      end
      if params[:competition_id].present?
        relation = relation.where(opta_competition_id: params[:competition_id])
      end
      relation.includes(:competition, :sport)
    end

    # Find bets and odds from Betclic for the given match
    def get_bets_on_match(match)
      Betclic.find_bets_on_match(match)
    end

  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def teams
    self.name.split(TEAM_NAMES_SEPERATOR)
  end

  def start_date
    self.start_at.to_date
  end
end
