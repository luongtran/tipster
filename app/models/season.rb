# == Schema Information
#
# Table name: seasons
#
#  id                  :integer          not null, primary key
#  opta_season_id      :string(255)
#  opta_competition_id :string(255)
#  name                :string(255)
#  start_date          :datetime
#  end_date            :datetime
#  created_at          :datetime
#  updated_at          :datetime
#

class Season < ActiveRecord::Base
  belongs_to :competition, foreign_key: :opta_competition_id, primary_key: :opta_competition_id
  validates :opta_season_id, uniqueness: true

end
