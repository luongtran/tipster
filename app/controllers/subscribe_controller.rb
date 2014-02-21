class SubscribeController < ApplicationController
  before_action :authenticate_user!, only: [:get_coupon_code, :payment]
  skip_before_filter :verify_authenticity_token, only: [:success]
  before_filter :ready_to_payment,only: [:payment,:payment_method]
  def identification
    action = params[:act]
    case action
      when 'update_profile'
        @profile = current_user.create_profile(profile_params)
      when 'facebook'
        session[:return_url] = register_url(step: 'identification')
        redirect_to user_omniauth_authorize_path(:facebook) and return
      when 'google'
        session[:return_url] = register_url(step: 'identification')
        redirect_to user_omniauth_authorize_path(:google_oauth2) and return
    end
  end

  # GET|POST /subscribe/payment
  def payment

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

      #@amount = Plan.calculate_amount(
      #    :plan_id => session[:plan_id],
      #    :tipster_count => tipster_ids_in_cart.size,
      #    :discount_code => 'change-me'
      #)
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
  # Hiển thị các cách thức thanh toán
  #
  def payment_method
      if request.get?
        # Calculate price
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
  # Hiển thị plan đã chọn + tipsters trong giỏ hàng + giá cả
  # Hành động có thể xảy ra trên page này:
  # 1. User muốn checkout -> payment_method
  # 2. Chọn plan khác -> redirect_to pricing page -> redirect to shopping_cart after choose plan
  # 3. Xóa || thêm tipster
  def choose_offer
    # Prepare shopping data
    @select_plan = Plan.where(id: session[:plan_id]).first
    @tipsters_in_cart = Tipster.where(id: tipster_ids_in_cart)
  end

  # TODO, shouldn 't skip_validate_csfr_token
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
      render :json => {success: true, :code => cc.code}
    else
      # TODO, edit error message here
      render :json => {success: false, :message => 'You can get more coupon'}
    end
  end

  #POST
  def apply_coupon_code
    cc = CouponCode.find_by_code(params[:code])
    if cc && cc.user_id == current_user.id
      cc.update_attributes(is_used: true)
      render :json => {success: true,:message => "Coupon using successfully !. Your has receiver 3 EUR"}
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

  def coupon_params
    params.permit!
  end

  def render_step(current_step)
    prepare_registration_data
    @current_step = current_step
    render ' users/register/steps '
  end

  def prepare_registration_data
    @data = {
        tipsters_in_cart: Tipster.where(id: tipster_ids_in_cart),
        selected_plan: Plan.where(id: session[:plan_id]).first
    }
    @data[:current_profile] = (@profile || current_user.find_or_initial_profile) if current_user
  end

  def ready_to_payment
    # check user is signed in, offer and at least on tipster in cart
    if !current_user
      flash.now[:alert] =   "Login !"
      redirect_to subscribe_identification_path
    elsif tipster_ids_in_cart.empty?
      flash.now[:alert]  =  "Please select tipster before checkout"
      redirect_to top_tipster_path
    elsif !session[:plan_id]
      flash.now[:alert]  = "Please select an plan"
      redirect_to  pricing_path
    end
  end

  def profile_params
    params[:profile].permit!
  end
end