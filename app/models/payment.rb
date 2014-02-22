class Payment < ActiveRecord::Base

  PAYMENT_METHODS = [BY_PAYPAL = 'paypal', BY_FRENCH_BANK = 'french_bank']

  belongs_to :subscription

  class << self
    def build_from_paypal(params = {})
      new params
    end
  end
end
