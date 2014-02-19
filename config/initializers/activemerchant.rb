if Rails.env.production?
  PAYPAL_ACCOUNT = 'thanhquang1988@gmail.com'
else
  PAYPAL_ACCOUNT = 'thanhquang1988-facilitator@gmail.com'
  ActiveMerchant::Billing::Base.mode = :test
end