# == Schema Information
#
# Table name: sports
#
#  id       :integer          not null, primary key
#  name     :string(255)      not null
#  position :integer
#

class Sport < ActiveRecord::Base
  has_and_belongs_to_many :tipsters
  has_many :bet_types
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  after_create :auto_position

  private
  def auto_position
    self.position ||= self.id
    self.save
  end
end
