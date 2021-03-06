if Rails.env.production?
  PAYPAL_ACCOUNT = 'sfr@tipsterhero.com'
  ActiveMerchant::Billing::Base.mode = :test
else
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
