class PaymentController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token, :only => [:notify,:return]
  # POST /payment
  # Initialize and redirect to Paypal payment page
  def create
    subscription = current_user.build_subscription(plan_id: session[:plan_id])
    tipsters = Tipster.where(id: tipster_ids_in_cart)
    subscription.tipsters << tipsters
    subscription.save
    @plan = Plan.find session[:plan_id]
    @paypal_obj = Hash.new
    @paypal_obj[:amount] = "%05.2f" % (subscription.calculator_price)
    @paypal_obj[:currency] = "EUR"
    @paypal_obj[:item_number] = current_user.id
    @paypal_obj[:item_name] = "TipsterHero Subscriptions"
    render 'remote.js.haml'
  end

  # GET /payment/return
  def return
    logger = Logger.new('log/paypal.log')
    logger.info("================== PAYPAL RETURN ON #{Time.now} =====================")
    logger.info(params)
    if params[:pending_reason] != ''
      flash[:alert] = PAYPAL_PENDINGS["#{params[:pending_reason]}"]
    end
    @message = PAYPAL_PENDINGS["#{params[:pending_reason]}"]
  end

  # POST /payment/notify
  def notify
    logger = Logger.new('log/paypal.log')
    logger.info("================== PAYPAL IPN ON #{Time.now} ========================")
    notify = Paypal::Notification.new(request.raw_post)
    logger.info(notify)
   # require 'debugger';debugger
#    notify.params['payment_status']
    puts "ITEM ID #{notify.item_id}"
    user = User.find(notify.item_id)
    subscription = user.subscription
    payment = subscription.payments.build(payment_date: notify.params['payment_date'],payer_first_name: notify.params['first_name'],payer_last_name: notify.params['last_name'],payer_email: notify.params['payer_email'],residence_country: notify.params['residence_country'],pending_reason: notify.params['pending_reason'],mc_currency: notify.params['mc_currency'],business_email:  notify.params['business'],payment_type:  notify.params['payment_type'],payer_status:  notify.params['payer_status'],test_ipn:  notify.params['test_ipn'],tax:  notify.params['tax'],txn_id:  notify.params['txn_id'],receiver_email:  notify.params['receiver_email'],payer_id:  notify.params['payer_id'],receiver_id:  notify.params['receiver_id'],payment_status:  notify.params['payment_status'],mc_gross:  notify.params['mc_gross'])
    payment.save
    # save payment data
    render nothing: true
  end
  # GET /payment/cancel
  def cancel
    redirect_to subscriptions_payment_path
  end
end
