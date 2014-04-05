# == Schema Information
#
# Table name: bet_types
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  sport_code :string(255)
#  name       :string(255)
#  other_name :string(255)
#  definition :string(255)
#  example    :string(255)
#  has_line   :boolean          default(TRUE)
#

class BetType < ActiveRecord::Base

  belongs_to :sport, foreign_key: :sport_code, primary_key: :code

  validates_presence_of :sport, :code, :name
  validates_uniqueness_of :code, allow_blank: true
  validates_uniqueness_of :name, scope: :sport_code, allow_blank: true

  class << self
  end

end
