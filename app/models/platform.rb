class Platform < ActiveRecord::Base
  validates :code, :name, uniqueness: {case_sensitive: false}
end
