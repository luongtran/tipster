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
#

class SubscriptionTipster < ActiveRecord::Base
  belongs_to :tipster
  belongs_to :subscription

  validates_uniqueness_of :tipster, scope: [:subscription]

  def set_active
    self.update_column(:active, true)
  end
end
