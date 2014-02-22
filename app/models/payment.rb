class Payment < ActiveRecord::Base

  PAYMENT_METHODS = [BY_PAYPAL = 'paypal', BY_FRENCH_BANK = 'french_bank']

  belongs_to :subscription

  class << self
    def build_from_paypal(params = {})
      new(
          payment_date: params['payment_date'],
          payer_first_name: params['first_name'],
          payer_last_name: params['last_name'],
          payer_email: params['payer_email'],
          residence_country: params['residence_country'],
          pending_reason: params['pending_reason'],
          mc_currency: params['mc_currency'],
          # FIXME, only a field is different !!!
          business_email: params['business'],
          payment_type: params['payment_type'],
          payer_status: params['payer_status'],
          test_ipn: params['test_ipn'],
          tax: params['tax'],
          txn_id: params['txn_id'],
          receiver_email: params['receiver_email'],
          payer_id: params['payer_id'],
          receiver_id: params['receiver_id'],
          payment_status: params['payment_status'],
          mc_gross: params['mc_gross']
      )
    end
  end
end
