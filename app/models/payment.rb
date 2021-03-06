# == Schema Information
#
# Table name: payments
#
#  id                :integer          not null, primary key
#  subscription_id   :integer
#  coupon_code_id    :integer
#  payment_date      :datetime
#  payer_first_name  :string(255)
#  payer_last_name   :string(255)
#  payer_email       :string(255)
#  residence_country :string(255)
#  pending_reason    :string(255)
#  mc_currency       :string(255)
#  business          :string(255)
#  payment_type      :string(255)
#  payer_status      :string(255)
#  test_ipn          :boolean
#  tax               :float
#  txn_id            :string(255)
#  receiver_email    :string(255)
#  payer_id          :string(255)
#  receiver_id       :string(255)
#  payment_status    :string(255)
#  mc_gross          :float
#  paykey            :string(255)
#  paid_for          :string(255)
#  tipster_ids       :string(255)
#  amount            :float
#  enable_history    :boolean          default(FALSE)
#  is_recurring      :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#

class Payment < ActiveRecord::Base

  PAYMENT_METHODS = [BY_PAYPAL = 'paypal', BY_FRENCH_BANK = 'french_bank']

  belongs_to :subscription

  def update_from_paypal(params = {})
    self.update_attributes(
        payment_date: params['payment_date'],
        payer_first_name: params['first_name'],
        payer_last_name: params['last_name'],
        payer_email: params['payer_email'],
        residence_country: params['residence_country'],
        pending_reason: params['pending_reason'],
        mc_currency: params['mc_currency'],
        business: params['business'],
        payment_type: params['payment_type'],
        payer_status: params['payer_status'],
        test_ipn: params['test_ipn'],
        tax: params['tax'],
        txn_id: params['txn_id'],
        receiver_email: params['receiver_email'],
        payer_id: params['payer_id'],
        receiver_id: params['receiver_id'],
        payment_status: params['payment_status'],
        mc_gross: params['mc_gross'],
        enable_history: true
    )
  end
end
