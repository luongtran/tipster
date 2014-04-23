class ManualMatch < ActiveRecord::Base

  belongs_to :sport, foreign_key: :sport_code, primary_key: :code
  validates_presence_of :name, :sport
end
