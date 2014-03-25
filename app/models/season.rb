# == Schema Information
#
# Table name: seasons
#
#  id                  :integer          not null, primary key
#  opta_season_id      :integer
#  opta_competition_id :integer
#  name                :string(255)
#  start_date          :datetime
#  end_date            :datetime
#  created_at          :datetime
#  updated_at          :datetime
#

class Season < ActiveRecord::Base

  belongs_to :competition, foreign_key: :opta_competition_id, primary_key: :opta_competition_id

  validates_uniqueness_of :opta_season_id, scope: [:opta_competition_id]
end
