class SubscriptionTipster < ActiveRecord::Base
  belongs_to :tipster
  belongs_to :subscription

  def set_active
    self.update_column(:active,true)
  end
end
