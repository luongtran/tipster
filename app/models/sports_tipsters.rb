# == Schema Information
#
# Table name: sports_tipsters
#
#  id         :integer          not null, primary key
#  sport_code :string(255)
#  tipster_id :integer
#

class SportsTipsters < ActiveRecord::Base
  belongs_to :sport, foreign_key: :sport_code, primary_key: :code
  belongs_to :tipster
  validates_uniqueness_of :tipster_id, scope: :sport_code
end
