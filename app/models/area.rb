# == Schema Information
#
# Table name: areas
#
#  id           :integer          not null, primary key
#  opta_area_id :integer
#  parent_id    :integer
#  name         :string(255)
#  fr_name      :string(255)
#  country_code :string(255)
#  active       :boolean          default(TRUE)
#

class Area < ActiveRecord::Base

  has_many :competitions, foreign_key: :opta_area_id, primary_key: :opta_area_id

  validates_uniqueness_of :opta_area_id

end
