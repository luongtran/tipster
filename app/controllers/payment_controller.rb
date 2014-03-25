class PaymentController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token, only: [:notify]

  # POST /payment/notify
  def notify
    logger = Logger.new('log/paypal.log')
    logger.info("PAYPAL IPN AT #{Time.now}")
    payment = Payment.find_by_paykey(params[:paykey])
    if payment
      notify = Paypal::Notification.new(request.raw_post)
      subscriber = Subscriber.find(notify.item_id)
      unless subscriber.account.confirmed?
        #subscriber.account.resend_confirmation_instructions
        #Send email problem !!!
      end
      subscription = payment.subscription
      payment.update_from_paypal notify.params
      subscription.update_attributes(using_coupon: false)

      if payment.amount.to_f == notify.params['mc_gross'].to_f
        if payment.paid_for == 'subscription'
          if notify.params['payment_status'] == "Completed"
            subscription.update_attributes(payment_status: Subscription::PAYMENT_STATUS[2])
            subscription.set_active
            subscription.subscription_tipsters.each do |t|
              t.set_active
            end
          elsif notify.params['payment_status'] == "Pending"
            logger.info("PAYPAL PENDING #{notify.params["pending_reason"]}")
            subscription.update_attributes(payment_status: Subscription::PAYMENT_STATUS[1])
          end
        elsif payment.paid_for == 'additional'
          if notify.params['payment_status'] == "Completed"
            tipster_ids = payment.tipster_ids.split(',').map(&:to_i)
            subscription.subscription_tipsters.each do |t|
              if tipster_ids.include?(t.tipster_id)
                t.set_active
              end
            end
          end
        else
          # Exception
          logger.info("Payment paid_for #{payment.paid_for}")
        end
      else
        logger.info("Payment amount wrong !!!!!!! #{payment.amount}  IPN #{notify.params['mc_gross']}")
      end
      payment.save
    else
      logger.info("IPN ERROR ON #{Time.now}")
      logger.info("Not found payment with PAYKEY = #{params[:paykey]}")
    end
    # find user by token
    render nothing: true
  end

end

