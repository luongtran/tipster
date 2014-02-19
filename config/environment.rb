# Load the Rails application.
require File.expand_path('../application', __FILE__)
#Requiring gems for e-commerce and paypal integration
require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'
#Including activemerchant helpers for being called inside rails views
ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
#Loading Paypal Error messages library
PAYPAL_PENDINGS = YAML.load_file("#{Rails.root}/config/paypal_pending_reasons.yml")[Rails.env]
# Initialize the Rails application.
TipsterHero::Application.initialize!
