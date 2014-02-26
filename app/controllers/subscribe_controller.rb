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
    if current_user.already_has_subscription? #Adding tipster to current subscription
      current_subscription = current_user.subscription
      unless current_subscription.can_change_tipster?
        redirect_to subscription_path,notice: "You can change your follow tipster on day #{current_subscription.active_date.strftime('%d')}  of the month" and return
      end
      select_plan = current_subscription.plan
      select_tipsters = Tipster.where(id: tipster_ids_in_cart)
      begin
        current_subscription.inactive_tipsters.delete_all
        current_subscription.tipsters << select_tipsters
        current_subscription.save
      rescue Exception => e
        logger = Logger.new('log/payment_errors.log')
        logger.info(e.message)
        logger.info(e.backtrace.first(5).join('/n'))
      end
      adder_tipster = current_subscription.adder_tipster
      subtotal = adder_tipster * ADDING_TIPSTER_PRICE
      before_amount = subtotal * select_plan.period
      if using_coupon?
        using_coupon = true
        current_subscription.update_attributes(using_coupon: true)
        amount = before_amount > 0 ? before_amount - 3 : before_amount
      else
        amount = before_amount
        using_coupon = false
      end
      @pp_object = {
          amount: amount.round(3),
          currency: 'EUR',
          item_number: current_user.id,
          item_name: "TipsterHero Adding #{select_tipsters.size} Tipster to Subscriptions #{current_subscription.plan_title}"
      }

      @return = {
          has_subscription: true,
          current_subscription: current_subscription,
          select_plan: select_plan,
          subtotal: subtotal,
          select_tipsters: select_tipsters,
          adder_tipster: adder_tipster,
          amount: amount.round(3),
          before_amount: before_amount.round(3),
          using_coupon: using_coupon

      }
    else # If user not completed his payment for subscription
      prepare_subscribe_info
      unless current_user.subscription
        subscription = current_user.build_subscription(plan_id: session[:plan_id])
      else
        subscription = current_user.subscription
      end
      select_plan = Plan.find session[:plan_id]
      select_tipsters = Tipster.where(id: tipster_ids_in_cart)
      subscription.tipsters = select_tipsters
      subscription.plan_id = session[:plan_id]
      subscription.active = false
      subscription.save
      adder_tipster = subscription.adder_tipster
      subtotal = select_plan.price + adder_tipster * ADDING_TIPSTER_PRICE
      before_amount = subscription.calculator_price
      if using_coupon?
        using_coupon = true
        subscription.update_attributes(using_coupon: true)
        amount = before_amount > 0 ? before_amount - 3 : before_amount
      else
        amount = before_amount
        using_coupon = false
      end
      @pp_object = {
          amount: amount.round(3),
          currency: 'EUR',
          item_number: current_user.id,
          item_name: "TipsterHero Subscriptions #{subscription.plan_title}"
      }
      @return = {
          has_subscription: false,
          select_plan: select_plan,
          adder_tipster: adder_tipster,
          select_tipsters: select_tipsters,
          subtotal: subtotal,
          amount: amount.round(3),
          before_amount: before_amount.round(3),
          using_coupon: using_coupon
      }
    end
  end

  # GET|POST /subscribe/payment_method
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

  # GET /subscribe/offer
  def choose_offer
    if current_user && current_user.already_has_subscription?
      @tipsters_in_cart = Tipster.where(id: tipster_ids_in_cart)
      @current_subscription = current_user.subscription
      @select_plan = @current_subscription.plan
      session[:plan_id] = @select_plan.id
      if !@tipsters_in_cart.blank?
        limit = @select_plan.number_tipster
        total = @tipsters_in_cart.size + @current_subscription.active_tipsters.size
        @total_price = (total > limit ? total - limit : 0) * ADDING_TIPSTER_PRICE * @select_plan.period
      end
    else
      # Prepare shopping data
      @select_plan = Plan.where(id: session[:plan_id]).first
      @tipsters_in_cart = Tipster.where(id: tipster_ids_in_cart)
      if @select_plan && !@tipsters_in_cart.blank?
        adding = @tipsters_in_cart.size > @select_plan.number_tipster ? @tipsters_in_cart.size - @select_plan.number_tipster : 0
        @total_price = (@select_plan.price + (adding * ADDING_TIPSTER_PRICE)) * @select_plan.period
      end
    end
  end

  # Return from paypal
  def success
    flash[:alert] = I18n.t("paypal_pending_reasons.#{params[:pending_reason]}") if params[:pending_reason]
    empty_subscribe_session
    @payment = current_user.subscription.payments.last
  end


  def get_coupon_code
    cc = CouponCode.create_for_user(current_user, coupon_params[:source])
    if cc
      render :json => {success: true, :code => cc.code, :message => I18n.t('coupon.created_successfully')}
    else
      # TODO, edit error message here
      render :json => {
          success: false,
          message: I18n.t('coupon.request_denied')
      }
    end
  end

  #POST
  def apply_coupon_code
    cc = CouponCode.find_by_code(params[:code])
    if cc && cc.user_id == current_user.id
      unless cc.is_used
        session[:using_coupon] = cc.id
        cc.mark_used
        flash[:notice] = I18n.t('coupon.success_using')
      else
        flash[:notice] = I18n.t('coupon.is_using')
      end
    else
      flash[:alert] = I18n.t('coupon.invalid')
    end
    redirect_to subscribe_payment_url
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
              elsif !session[:plan_id] && (!current_user.subscription || !current_user.subscription.active)
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


  def using_coupon?
    if session[:using_coupon]
      if CouponCode.exists?(session[:using_coupon])
        cc = CouponCode.find session[:using_coupon]
        return current_user.coupon_codes.include? cc
      end
    else
      return false
    end
  end
end