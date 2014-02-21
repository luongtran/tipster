class SubscribeController < ApplicationController
  before_action :authenticate_user!, only: [:get_coupon_code, :payment]
  skip_before_filter :verify_authenticity_token, only: [:success]
  before_action :ready_to_payment, only: [:payment, :payment_method]

  def identification
    action = params[:act]
    case action
      when 'update_profile'
        @profile = current_user.create_profile(profile_params)
      when 'facebook', 'google_oauth2'
        session[:return_url] = subscribe_payment_method_url
        redirect_to user_omniauth_authorize_path(action)
    end
  end

  # GET|POST /subscribe/payment
  def payment
    prepare_subscribe_info
    # Calculate amount and show the paypal form
    unless current_user.subscription
      subscription = current_user.build_subscription(plan_id: session[:plan_id])
    else
      subscription = current_user.subscription
    end

    tipsters = Tipster.where(id: tipster_ids_in_cart)
    subscription.tipsters = tipsters
    subscription.plan_id = session[:plan_id]
    subscription.save

    @amount = subscription.calculator_price
    @pp_object = Hash.new
    @pp_object[:amount] = "%05.2f" % @amount
    @pp_object[:currency] = "EUR"

    # Reply item_number by token of payment
    @pp_object[:item_number] = current_user.id
    @pp_object[:item_name] = "TipsterHero Subscriptions #{subscription.plan.title}"

    client = TwitterOAuth::Client.new(
        :consumer_key => TWITTER_CONSUMER_KEY,
        :consumer_secret => TWITTER_CONSUMER_SECRET
    )
    request_token = client.request_token(:oauth_callback => tweet_twitter_url)
    session[:request_token] = request_token
    @twitter_url = request_token.authorize_url

  end

  # GET|POST /register/payment_method
  def payment_method
    if request.get?
      # Re-calculate the amount
    else
      # Get the payment method selected
      method = params[:method]
      if method == Payment::BY_PAYPAL
        # Redirect to 'payment' action
        redirect_to subscribe_payment_url
      elsif method == Payment::BY_FRENCH_BANK
        # Redirect to action paywith_french_bank
        flash.now[:notice] = 'Sorry, French bank feature is unavailable!'
      else
        render_bad_request
      end
    end
  end

  # GET /register/offer
  def choose_offer
    # Prepare shopping data
    @select_plan = Plan.where(id: session[:plan_id]).first
    @tipsters_in_cart = Tipster.where(id: tipster_ids_in_cart)
  end

  # TODO, shouldn't skip_validate_csfr_token
  # Return from paypal
  def success
    flash[:alert] = I18n.t("paypal_pending_reasons.#{'address'}") if params[:pending_reason].presence
    empty_subscribe_session
    @message = PAYPAL_PENDINGS["#{params[:pending_reason]}"]
    @payment = current_user.subscription.payments.last
  end


  def get_coupon_code
    cc = CouponCode.create_for_user(current_user, coupon_params[:source])
    if cc
      render :json => {success: true, :code => cc.code, :message => 'Coupon create'}
    else
      # TODO, edit error message here
      render :json => {
          success: false,
          :message => 'You can get more coupon'
      }
    end
  end

  #POST
  def apply_coupon_code
    cc = CouponCode.find_by_code(params[:code])
    if cc && cc.user_id == current_user.id
      session[:coupon_code_id] = cc.id
      render :json => {success: true, :message => "Coupon using successfully !. Your has receiver 3 EUR"}
    else
      render :json => {success: false, :message => "Your counpon code is invalid !"}
    end
  end

  #POST
  def deny_coupon_code
    cc = CouponCode.find_by_code(params[:code])
    if cc
      cc.update_attributes(is_deny: true)
    else

    end
  end

  private

  def prepare_subscribe_info
    @select_plan = Plan.where(id: session[:plan_id]).first
    @select_tipsters = Tipster.where(id: tipster_ids_in_cart)
  end

  def coupon_params
    params.permit!
  end

  def ready_to_payment
    checker = if !current_user
                {
                    message: "Please login or signup !",
                    url: subscribe_identification_url
                }
              elsif tipster_ids_in_cart.empty?
                {
                    message: "Please choose at least one tipster",
                    url: top_tipster_url
                }
              elsif !session[:plan_id]
                {
                    message: "Please choose a plan",
                    url: pricing_url
                }
              else
                nil
              end
    redirect_to checker[:url], alert: checker[:message] and return if checker.present?
  end

  def profile_params
    params[:profile].permit!
  end
end