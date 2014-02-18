ActiveMerchant::Billing::Base.mode = :test
PAYPAL_CONFIG = YAML.load_file("#{Rails.root}/config/paypal.yml")[Rails.env].symbolize_keys