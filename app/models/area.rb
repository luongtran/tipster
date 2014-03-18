class Area < ActiveRecord::Base
  validates_uniqueness_of :area_id, :country_code
end
