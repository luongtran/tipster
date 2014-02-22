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
    if already_has_subscription?
      @already_has_subscription = true

      @current_subscription = current_user.subscription
      @select_plan = @current_subscription.plan
      @select_tipsters = Tipster.where(id: tipster_ids_in_cart)
      begin
      @current_subscription.tipsters << @select_tipsters
      rescue Exception => e
      end
      @current_subscription.save
      limit = [@current_subscription.tipsters.size, @select_plan.number_tipster].max
      total = @select_tipsters.size + @current_subscription.tipsters.size
      @adding_tipster = (total - limit) > 0 ? total - limit : 0
      @amount = @adding_tipster * ADDING_TIPSTER_PRICE * @select_plan.period
      @pp_object = {
          amount: @amount.round(3),
          currency: 'EUR',
          item_number: current_user.id,
          item_name: "TipsterHero Adding #{@select_tipsters.size} Tipster to Subscriptions #{@current_subscription.plan_title}"
      }
    else
      prepare_subscribe_info
      # Calculate amount and show the paypal form
      unless current_user.subscription
        subscription = current_user.build_subscription(plan_id: session[:plan_id])
      else
        subscription = current_user.subscription
      end
      @select_tipsters ||= Tipster.where(id: tipster_ids_in_cart)
      subscription.tipsters = @select_tipsters
      subscription.plan_id = session[:plan_id]
      subscription.active = false
      subscription.save
      @amount = subscription.calculator_price
      @pp_object = {
          amount: @amount.round(3),
          currency: 'EUR',
          item_number: current_user.id,
          item_name: "TipsterHero Subscriptions #{subscription.plan_title}"
      }
    end
  end

  # GET|POST /register/payment_method
  def payment_method
    if request.post?
      # Get the payment method selected
      method = params[:method]
      if method == Payment::BY_PAYPAL
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
    if @select_plan && !@tipsters_in_cart.blank?
      adding = @tipsters_in_cart.size > @select_plan.number_tipster ? @tipsters_in_cart.size - @select_plan.number_tipster : 0
      @total_price = (@select_plan.price + (adding * ADDING_TIPSTER_PRICE)) * @select_plan.period
      if session[:coupon_code_id]
        @total_price -= 3
      end
    end
  end

  # GET /register/offer
  def add_offer
    # Prepare shopping data
    @tipsters_in_cart = Tipster.where(id: tipster_ids_in_cart)
    @current_subscription = current_user.subscription
    @current_plan = @current_subscription.plan
    session[:plan_id] = @current_plan.id
    if !@tipsters_in_cart.blank?
      limit = [@current_subscription.tipsters.size, @current_plan.number_tipster].max
      total = @tipsters_in_cart.size + @current_subscription.tipsters.size
      @total_price = (total > limit ? total - limit : 0) * ADDING_TIPSTER_PRICE * @current_plan.period
    end
  end

  # TODO, shouldn't skip_validate_csfr_token
  # Return from paypal
  def success
    flash[:alert] = I18n.t("paypal_pending_reasons.#{params[:pending_reason]}") if params[:pending_reason]
    empty_subscribe_session
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
      cc.update_attributes({is_used: true,used_at: Time.now})
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
                    url: top_tipsters_url
                }
              elsif !session[:plan_id] && !current_user.subscription.active
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

  def already_has_subscription?
    current_user && current_user.subscription && current_user.subscription.active == true
  end

  def using_coupon?
    current_user
  end

end