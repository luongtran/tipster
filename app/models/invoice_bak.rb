#class Invoice < ActiveRecord::Base
#
#  # TODO,
#  TYPES = []
#
#  # ==============================================================================
#  # ASSOCIATIONS
#  # ==============================================================================
#  belongs_to :user
#
#  # ==============================================================================
#  # VALIDATIONS
#  # ==============================================================================
#  validates_uniqueness_of :token
#  validates_uniqueness_of :transaction_id, if: Proc.new { |p| p.completed? }, on: :update
#  validates :amount, :user, presence: true
#  validates_numericality_of :amount, greater_than_or_equal_to: 1
#  # ==============================================================================
#  # SCOPE
#  # ==============================================================================
#  scope :completed, -> { where(completed: true) }
#
#  # ==============================================================================
#  # INSTANCE METHODS
#  # ==============================================================================
#
#  # Initial transaction & return redirect uri
#  def setup!(user, return_url, cancel_url, amount)
#    self.amount = amount
#    response = client.setup(
#        payment_request,
#        return_url,
#        cancel_url,
#        pay_on_paypal: true
#    )
#    self.token = response.token
#    self.user = user
#    self.save!
#    response.redirect_uri
#  end
#
#  def cancel
#    self.canceled = true
#    self.save!
#    self
#  end
#
#  # Checkout process
#  def complete!(payer_id = nil)
#    response = client.checkout!(
#        self.token,
#        payer_id,
#        payment_request
#    )
#    self.payer_id = payer_id
#    self.transaction_id = response.payment_info.first.transaction_id
#    self.completed = true
#    self.save!
#    self
#  end
#
#  # ==============================================================================
#  # PRIVATE METHODS
#  # ==============================================================================
#  private
#
#  # Create paypal client
#  def client
#    Paypal::Express::Request.new PAYPAL_CONFIG
#  end
#
#  # Generate a payment request
#  def payment_request
#    Paypal::Payment::Request.new(
#        :amount => self.amount,
#        # TODO, change the description
#        :description => 'Tipster Hero payment'
#    )
#  end
#end
