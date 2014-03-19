# == Schema Information
#
# Table name: bet_types
#
#  id         :integer          not null, primary key
#  sport_id   :integer
#  code       :string(255)
#  name       :string(255)
#  other_name :string(255)
#  definition :string(255)
#  example    :string(255)
#  has_line   :boolean          default(TRUE)
#

class BetType < ActiveRecord::Base
  belongs_to :sport
  validates_presence_of :sport
  validates_uniqueness_of :code, :name, scope: :sport_id
end
