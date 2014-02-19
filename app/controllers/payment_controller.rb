class PaymentController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token, :only => [:notify,:return]
  # POST /payment
  # Initialize and redirect to Paypal payment page
  def create
    @plan = Plan.find session[:plan_id]
    @paypal_obj = Hash.new
    @paypal_obj[:amount] = "%05.2f" % (@plan.price)
    @paypal_obj[:currency] = "EUR"
    @paypal_obj[:item_number] = current_user.id
    @paypal_obj[:item_name] = "TipsterHero Subscriptions"
    current_user.build_subscription(plan_id: session[:plan_id])
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
    @params = params
  end

  # POST /payment/notify
  def notify
    logger = Logger.new('log/paypal.log')
    logger.info("================== PAYPAL IPN ON #{Time.now} ========================")
    notify = Paypal::Notification.new(request.raw_post)
    logger.info(notify)
   # require 'debugger';debugger
#    notify.params['payment_status']
    user = User.find(notify.item_id)
    subscription = user.build_subscription
    # save payment data
    render nothing: true
  end
  # GET /payment/cancel
  def cancel
    redirect_to subscriptions_payment_path
  end
end