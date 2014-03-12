class BetType < ActiveRecord::Base
  belongs_to :sport
  validates_presence_of :sport
  validates_uniqueness_of :code, :name, scope: :sport_id
end