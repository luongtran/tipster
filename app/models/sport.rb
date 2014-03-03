# == Schema Information
#
# Table name: sports
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#

class Sport < ActiveRecord::Base

  has_and_belongs_to_many :tipsters, class_name: 'Tipster', foreign_key: :sport_id, association_foreign_key: :user_id, join_table: "sports_users"

  validates :name, presence: true, uniqueness: {case_sensitive: false}
end
