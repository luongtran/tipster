class SubscribeController < ApplicationController
  before_action :authenticate_account!, only: [:get_coupon_code, :payment_old]
  skip_before_filter :verify_authenticity_token, only: [:success]
  before_action :ready_to_payment, only: [:payment_old, :payment_method]
=begin
  def identification
    unless current_account
      @subscriber = Subscriber.new
      @subscriber.build_account
    end
    action = params[:act]
    case action
      when 'sign_in'
        @account = Account.find_by(email: params[:account][:email])
        if @account && @account.valid_password?(params[:account][:password])
          sign_in @account
          #@result = true
          redirect_to subscribe_payment_method_url
        else
          #@result = false
          flash.now[:alert] = 'Email or password is invalid'
        end
      when 'sign_up'
        subscriber_params = params.require(:subscriber).
            permit(:first_name, :last_name, account_attributes: [:email, :password, :password_confirmation])
        @subscriber = Subscriber.register(subscriber_params)
        if @subscriber.save
          sign_in(:account, @subscriber.account)
          redirect_to subscribe_payment_method_url
        end
      when 'facebook', 'google_oauth2'
        session[:return_url] = subscribe_payment_method_url
        redirect_to account_omniauth_authorize_path(action)
    end
  end

  # GET|POST /subscribe/payment

  def payment_old
    if current_subscriber.already_has_subscription? #Adding tipster to current subscription
      current_subscription = current_subscriber.subscription
      unless current_subscription.can_change_tipster?
        redirect_to subscriptions_path, notice: "You can change your follow tipster on day #{current_subscription.active_at.strftime('%d')}  of the month" and return
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
          item_number: current_subscriber.id,
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
      unless current_subscriber.subscription
        subscription = current_subscriber.build_subscription(plan_id: session[:plan_id])
      else
        subscription = current_subscriber.subscription
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
          item_number: current_subscriber.id,
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
=end
  #Adding tipster to current subscription
  #Validate current subscription is active & select tipster < limit
  def add_tipster
    current_subscription = current_subscriber.subscription
    select_plan = current_subscription.plan
    select_tipsters = Tipster.where(id: tipster_ids_in_cart)
    if request.post?
      if current_subscription.active? && current_subscription.active_tipsters.size + select_tipsters.size <= current_subscription.plan.number_tipster
        select_tipsters.each do |tipster|
          if current_subscription.tipsters.include?(tipster)
            puts "TH1"
            current_subscription.change_tipster(tipster)
          else
            puts "TH2"
            current_subscription.insert_tipster(tipster)
          end
        end
        redirect_to subscriptions_path and return
      else
        flash[:alert] = "SYSTEM ERROR !!!!"
        redirect_to subscriptions_path and return
      end
    else
      @return = {
          has_subscription: true,
          current_subscription: current_subscription,
          select_plan: select_plan,
          select_tipsters: select_tipsters
      }
    end
  end

  #Change subscription plan
  def change_plan
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
  # Require choosen a plan
  def choose_offer
    if current_subscriber && current_subscriber.already_has_subscription?
      @tipsters_in_cart = Tipster.where(id: tipster_ids_in_cart)
      @current_subscription = current_subscriber.subscription
      @select_plan = @current_subscription.plan
      session[:plan_id] = @select_plan.id
      if !@tipsters_in_cart.blank?
        limit = [@select_plan.number_tipster, @current_subscription.active_tipsters.size].max
        total = @tipsters_in_cart.size + @current_subscription.active_tipsters.size
        @total_price = (total > limit ? total - limit : 0) * ADDING_TIPSTER_PRICE * @select_plan.period
        if @total_price == 0
          redirect_to action: 'add_tipster' and return
        end
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
    @payment = current_subscriber.subscription.payments.last
  end


  def get_coupon_code
    cc = CouponCode.create_for_user(current_subscriber, coupon_params[:source])
    if cc
      session[:using_coupon] = cc.id
      render :json => {
          success: true,
          code: cc.code,
          message: I18n.t('coupon.created_successfully')
      }
    else
      render :json => {
          success: false,
          message: I18n.t('coupon.request_denied')
      }
    end
  end

  # ========== NEW ==================================================
  # Request checkout the cart
  def checkout
    if current_account
      # require selected offer before go to personal information
      redirect_to subscribe_personal_information_url
    else
      redirect_to subscribe_account_url
    end
  end

  def account
    if account_signed_in?
      redirect_to subscribe_personal_information_url and return
    end
    if request.get?
      @account = Account.new
    else
      # Create account
      @account = Account.build_with_rolable(account_params, Subscriber)
      if @account.save
        sign_in @account
        redirect_to subscribe_personal_information_url
      end
    end
  end

  def personal_information
    unless account_signed_in?
      redirect_to subscribe_account_url and return
    end
    if selected_plan
      @select_plan = selected_plan
      @account = current_account
      @subscriber = @account.rolable
      if request.post?
        @subscriber.validate_with_paid_account = !@select_plan.free?
        if @subscriber.update_attributes(profile_params)
          # Apply free plan
          if selected_plan.free?
            current_subscriber.subscription.delete
            subscription = current_subscriber.build_subscription(plan: selected_plan, is_free: true, active: true)
            subscription.save
            empty_cart_session
            session[:subscription_registered] = true
            render :welcome
          else
            redirect_to subscribe_shared_url
          end
        end
      end
    else
      redirect_to pricing_url, notice: 'Please choose a plan'
    end
  end

  def shared

  end

  def receive_methods
    unless account_signed_in?
      redirect_to subscribe_personal_information_url and return
    end
    @account = current_account
    @subscriber = @account.rolable
    if request.post?
      @subscriber.update_receive_tips_method(params[:receive_tip_methods])
      redirect_to subscribe_payment_url
    end
  end

  def welcome

  end

  private

  def profile_params
    params.require(:subscriber).permit(
        :first_name, :last_name, :nickname, :gender, :receive_tip_methods, :birthday, :address, :city, :country, :zip_code, :mobile_phone,
        :telephone, :favorite_beting_website, :know_website_from, :secret_question, :answer_secret_question, :receive_info_from_partners,
        :humanizer_answer, :humanizer_question_id
    )
  end

  def prepare_subscribe_info
    @select_plan = Plan.where(id: session[:plan_id]).first
    @select_tipsters = Tipster.where(id: tipster_ids_in_cart)
  end

  def coupon_params
    params.permit!
  end

  def ready_to_payment
    checker = if !current_subscriber
                {
                    message: "Please login or signup !",
                    url: subscribe_identification_url
                }
              elsif tipster_ids_in_cart.empty?
                {
                    message: "Please choose at least one tipster",
                    url: tipsters_url
                }
              elsif !session[:plan_id] && (!current_subscriber.subscription || !current_subscriber.subscription.active)
                {
                    message: "Please choose a plan",
                    url: pricing_url
                }
              else
                nil
              end
    redirect_to checker[:url], alert: checker[:message] and return if checker.present?
  end

  def using_coupon?
    if session[:using_coupon]
      if CouponCode.exists?(session[:using_coupon])
        cc = CouponCode.find session[:using_coupon]
        return current_subscriber.coupon_codes.include? cc
      end
    else
      return false
    end
  end
end