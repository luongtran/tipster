class SubscriptionTipster < ActiveRecord::Base
  belongs_to :tipster
  belongs_to :subscription

  validates_uniqueness_of :tipster, scope: [:subscription]

  def set_active
    puts "F"
    self.update_column(:active, true)
  end
end
