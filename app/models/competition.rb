# == Schema Information
#
# Table name: competitions
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  name           :string(255)
#  area_id        :integer
#  active         :boolean          default(TRUE)
#  country_code   :string(255)
#

class Competition < ActiveRecord::Base
  has_many :seasons, foreign_key: :competition_id
  validates_uniqueness_of :competition_id
end
