# == Schema Information
#
# Table name: sports
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#

class Sport < ActiveRecord::Base
  has_and_belongs_to_many :tipsters
  validates :name, presence: true, uniqueness: {case_sensitive: false}

end
