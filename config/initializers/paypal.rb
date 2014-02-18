require 'paypal/express'
PAYPAL_CONFIG = YAML.load_file("#{Rails.root}/config/paypal.yml")[Rails.env].symbolize_keys
Paypal.sandbox! if PAYPAL_CONFIG[:sandbox]