class Competition < ActiveRecord::Base
  validates_uniqueness_of :competition_id
end
