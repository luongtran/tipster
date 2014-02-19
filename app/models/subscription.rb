class Subscription < ActiveRecord::Base
  has_many :tipsters , through: :subscriber_tipsters
  belongs_to :user
end
