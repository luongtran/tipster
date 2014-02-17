class SubscriberTipster < ActiveRecord::Base
  belongs_to :tipster
  belongs_to :subscription
end
