# == Schema Information
#
# Table name: areas
#
#  id             :integer          not null, primary key
#  area_id        :string(255)
#  name           :string(255)
#  country_code   :string(255)
#  parent_area_id :string(255)
#  active         :boolean          default(TRUE)
#

class Area < ActiveRecord::Base
  has_many :competitions, foreign_key: :opta_area_id, primary_key: :area_id
  validates_uniqueness_of :area_id, :country_code
end
