class PaymentController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token, only: [:notify]

  # POST /payment/notify
  def notify
    # find user by token
    notify = Paypal::Notification.new(request.raw_post)
    subscriber = Subscriber.find(notify.item_id)
    unless subscriber.account.confirmed?
      subscriber.account.resend_confirmation_instructions
    end
    subscription = subscriber.subscription
    payment = subscription.payments.build_from_paypal notify.params
    subscription.update_attributes(using_coupon: false)
    if notify.params['payment_status'] == "Completed"
      subscription.subscription_tipsters.each do |t|
        t.set_active
      end
      unless subscription.active?
        subscription.set_active
      end
    end
    payment.save
    render nothing: true
  end

end

