class SubscribeController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:success]

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
    if is_ready_to_payment?
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

    else
      # Check the payment conditions, display notice and redirect user back to the suite step
      redirect_to subscribe_identification_path
    end
  end

  # GET|POST /register/payment_method
  # Hiển thị các cách thức thanh toán
  #
  def payment_method
    #if is_ready_to_payment?
    if is_ready_to_payment?
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
    else
      flash[:alert] = "You cannot checkout for now!"
      redirect_to subscribe_choose_offer_url
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

  private

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

  def is_ready_to_payment?
    # check user is signed in, offer and at least on tipster in cart
    !(!current_user || tipster_ids_in_cart.empty? || !session[:plan_id])
    # TODO, validate tipsters, plan_id here ....
  end

  def profile_params
    params[:profile].permit!
  end
end