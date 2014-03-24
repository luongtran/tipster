# == Schema Information
#
# Table name: subscription_tipsters
#
#  id              :integer          not null, primary key
#  tipster_id      :integer
#  subscription_id :integer
#  active          :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#  is_primary         :boolean
#

class SubscriptionTipster < ActiveRecord::Base
  belongs_to :tipster
  belongs_to :subscription
  has_one :payment
  scope :primary_tipster, -> { where(:is_primary => true) }
  validates_uniqueness_of :tipster, scope: [:subscription]

  def set_active
    if self.is_primary
      self.update_attributes(
          active: true,
          active_at: Time.now,
          expired_at: self.subscription.expired_at
      )
    else
      self.update_attributes(
          active: true,
          active_at: Time.now,
          expired_at: Time.now + 1.month
      )
    end
  end

  def active_string
    self.active? ? "Paid" : "Not paid"
  end

  def expired
    self.update_column(:active, false)
  end

end
