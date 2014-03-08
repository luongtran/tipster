class SubscribeController < ApplicationController
  before_action :authenticate_account!, only: [:get_coupon_code, :payment_old]
  skip_before_filter :verify_authenticity_token, only: [:success]
  before_action :ready_to_payment, only: [:payment_old, :payment_method]

  # Adding tipster to current subscription
  # Validate current subscription is active & select tipster < limit
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
        redirect_to subscription_path and return
      else
        flash[:alert] = "SYSTEM ERROR !!!!"
        redirect_to subscription_path and return
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

  # Change subscription plan
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
            current_subscriber.apply_plan(selected_plan)
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

  #Calculating price and redirect to paypal
  #User is sign_in
  #Only apply for first time payment
  def payment
    @select_plan = Plan.find(session[:plan_id])
    @tipsters = Tipster.where(id: tipster_ids_in_cart)
    unless current_subscriber.subscription.present?
      @subscription = current_subscriber.build_subscription(plan_id: session[:plan_id])
    else
      @subscription = current_subscriber.subscription
    end
    @subscription.tipsters = @tipsters unless current_subscriber.already_has_subscription?
    @subscription.using_coupon = true if using_coupon?
    @subscription.save

    if request.post?
      if params[:method] == Payment::BY_PAYPAL
        @paypal = Hash.new
        @paypal[:amount] = "%05.2f" % @subscription.calculator_price
        @paypal[:currency] = "EUR"
        @paypal[:item_number] = current_subscriber.id
        @paypal[:item_name] = "TIPSTER HERO SUBSCRIPTION"
        respond_to do |format|
          format.js { render 'paypalinit.js.haml' }
        end
      else
        puts "FRENCH BANK HERE"
      end
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