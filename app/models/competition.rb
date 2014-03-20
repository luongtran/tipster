# == Schema Information
#
# Table name: competitions
#
#  id                  :integer          not null, primary key
#  opta_competition_id :string(255)
#  name                :string(255)
#  opta_area_id        :string(255)
#  country_code        :string(255)
#  active              :boolean          default(TRUE)
#  created_at          :datetime
#  updated_at          :datetime
#

class Competition < ActiveRecord::Base
  has_many :seasons, foreign_key: :opta_competition_id, primary_key: :opta_competition_id
  has_many :matches, foreign_key: :opta_competition_id, primary_key: :opta_competition_id
  validates_uniqueness_of :opta_competition_id, scope: :opta_area_id
end
