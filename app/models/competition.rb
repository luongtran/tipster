# == Schema Information
#
# Table name: competitions
#
#  id                  :integer          not null, primary key
#  opta_competition_id :integer
#  opta_area_id        :integer
#  sport_code          :string(255)
#  name                :string(255)
#  fr_name             :string(255)
#  active              :boolean          default(TRUE)
#

class Competition < ActiveRecord::Base

  belongs_to :area, foreign_key: :opta_area_id, primary_key: :opta_area_id

  belongs_to :sport, foreign_key: :sport_code, primary_key: :code

  has_many :seasons, foreign_key: :opta_competition_id, primary_key: :opta_competition_id

  has_many :matches, foreign_key: :opta_competition_id, primary_key: :opta_competition_id

  validates :sport_code, presence: true

  validates_uniqueness_of :opta_competition_id, scope: :opta_area_id


  # Area -> Competition -> Season -> Round -> Match
end
