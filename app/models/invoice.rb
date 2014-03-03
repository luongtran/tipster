# == Schema Information
#
# Table name: invoices
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  amount         :integer          default(1)
#  currency       :string(255)
#  token          :string(255)
#  transaction_id :string(255)
#  payer_id       :string(255)
#  completed      :boolean          default(FALSE)
#  canceled       :boolean          default(FALSE)
#  payment_type   :integer
#  created_at     :datetime
#  completed_at   :datetime
#

class Invoice < ActiveRecord::Base

  # TODO,
  TYPES = []

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :subscriber

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates_uniqueness_of :token
  validates_uniqueness_of :transaction_id, if: Proc.new { |p| p.completed? }, on: :update
  validates :amount, :subscriber, presence: true
  validates_numericality_of :amount, greater_than_or_equal_to: 1

  # ==============================================================================
  # SCOPE
  # ==============================================================================
  scope :completed, -> { where(completed: true) }

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self

  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def cancel
    self.canceled = true
    self.save!
  end

  def complete(trans_id)
    self.transaction_id = trans_id
    self.completed = true
    self.save!
  end

  private

  def gateway
    ActiveMerchant::Billing::PaypalExpressGateway.new PAYPAL_CONFIG
  end

end
