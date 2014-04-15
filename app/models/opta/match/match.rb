class Opta::Match::Match < ActiveRecord::Base

  belongs_to :sport, foreign_key: :sport_code, primary_key: :sport_code
  validates :opta_match_id, :sport_code, presence: true

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def name
  end
end
