class Sport < ActiveRecord::Base

  has_many :tipsters

  validates :name, presence: true, :uniqueness => {:case_sensitive => false}
end
