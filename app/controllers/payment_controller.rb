class PaymentController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token, :only => [:notify, :return]

  # POST /payment
  # Initialize and redirect to Paypal payment page
  def create
    unless current_user.subscription
      # What if plan_id is non-exist ?
      subscription = current_user.build_subscription(plan_id: session[:plan_id])
    else
      subscription = current_user.subscription
    end

    # Move these lines bellow to model
    tipsters = Tipster.where(id: tipster_ids_in_cart)
    subscription.tipsters = tipsters
    subscription.plan_id = session[:plan_id]
    subscription.save

    # Move these lines bellow to model
    @paypal_obj = Hash.new
    @paypal_obj[:amount] = "%05.2f" % (subscription.calculator_price)
    @paypal_obj[:currency] = "EUR"
    @paypal_obj[:item_number] = current_user.id

    @paypal_obj[:item_name] = "TipsterHero Subscriptions #{subscription.plan_title}"
    render 'remote.js.haml'
  end

  # GET /payment/return
  def return
    logger = Logger.new('log/paypal.log')
    logger.info("================== PAYPAL RETURN ON #{Time.now} =====================")
    logger.info(params)
    if params[:pending_reason] != ''
      flash[:alert] = I18n.t("paypal_pending_reasons.#{params[:pending_reason]}")
    end
    session.delete(:cart)
    session.delete(:plan_id)
    @message = I18n.t("paypal_pending_reasons.#{params[:pending_reason]}")
    @payment = current_user.subscription.payments.last
  end

  # POST /payment/notify
  def notify
    # find user by token
    notify = Paypal::Notification.new(request.raw_post)
    user = User.find(notify.item_id)
    subscription = user.subscription
    payment = subscription.payments.build_from_paypal notify.params
    subscription.update_attributes(using_coupon: false)
    if notify.params['payment_status'] == "Completed"
        subscription.subscription_tipsters.each do |t|
          t.set_active
        end
      unless subscription.active?
          subscription.update_attributes({active: true,active_date: Time.now,expired_date: Time.now + subscription.plan.period.month})
      end
    end
    payment.save
    render nothing: true
  end

  # GET /payment/cancel
  def cancel
    redirect_to subscribe_payment_path
  end

end

