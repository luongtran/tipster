if Rails.env.production?
  #PAYPAL_ACCOUNT = 'thanhquang1988@gmail.com'
  ADDING_TIPSTER_PRICE = 9.9 # TODO, move this constant to Plan model
  PAYPAL_ACCOUNT = 'sfr@tipsterhero.com'
  ActiveMerchant::Billing::Base.mode = :test
else
  ADDING_TIPSTER_PRICE = 9.9
  PAYPAL_ACCOUNT = 'sfr@tipsterhero2.com'
  ActiveMerchant::Billing::Base.mode = :test
end

require "paypal/recurring"

PayPal::Recurring.configure do |config|
  config.sandbox = true
  config.username = "sfr_api1.tipsterhero.com"
  config.password = "1392864255"
  config.signature = "APG7j5L8ZUJFIYlaATsYy1brZQEAAoM6dTzBBkfnxjxtgCqyZW..XMBg"
end
