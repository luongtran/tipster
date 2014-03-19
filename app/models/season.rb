# == Schema Information
#
# Table name: seasons
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  season_id      :string(255)
#  start_date     :datetime
#  end_date       :datetime
#  competition_id :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Season < ActiveRecord::Base
  belongs_to :competition, foreign_key: :competition_id
  validates :season_id, uniqueness: true

end
