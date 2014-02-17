class Subscription < ActiveRecord::Base
  has_many :tipsters , through: :subscriber_tipsters
end
