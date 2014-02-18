class Invoice < ActiveRecord::Base

  # TODO,
  TYPES = []

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :user

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates_uniqueness_of :token
  validates_uniqueness_of :transaction_id, if: Proc.new { |p| p.completed? }, on: :update
  validates :amount, :user, presence: true
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
