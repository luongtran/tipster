class SubscribeController < ApplicationController
  before_action :authenticate_account!, only: [:get_coupon_code]
  before_action :no_subscription_required, except: [:success]
  before_action :load_subscribe_data
  skip_before_filter :verify_authenticity_token, only: [:success]

  # Return from paypal
  def success
    flash[:alert] = I18n.t("paypal_pending_reasons.#{params[:pending_reason]}") if params[:pending_reason]
    empty_subscribe_session
    # Critial error when IPN not working !!!
    @payment = current_subscriber.subscription.payments.last
  end

  def get_coupon_code
    cc = CouponCode.create_for_user(current_subscriber, coupon_params[:source])
    if cc
      current_subscriber.subscription.update_attributes(using_coupon: true)
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
    if current_account && session[:step] > 2
      go_to_current_steps
    else
      redirect_to subscribe_personal_information_url
    end
  end

  def account
    @step = 3
    session[:step] = 3
    if account_signed_in?
      redirect_to subscribe_personal_information_url and return
    end
    if @select_plan.nil?
      flash[:alert] = I18n.t('errors.messages.unselect_plan')
      redirect_to pricing_path and return
    end
    if request.get?
      @account = Account.new
      @account2 = Account.new
    else
      # Create account
      case params[:act]
        when 'sign_in'
          @account2 = Account.find_by_email(params[:account][:email])
          if @account2 && @account2.valid_password?(params[:account][:password])
            sign_in @account2
            redirect_to subscribe_personal_information_url
          else
            # Render error !
            @account = Account.new
            @account2 = Account.new
            @error = true
          end
        when 'sign_up'
          @account = Account.build_with_rolable(account_params, Subscriber)
          if @account.save
            sign_in @account
            redirect_to subscribe_personal_information_url
          else
            # Render error !
            @account2 = Account.new
          end
      end
    end
  end

  # listing all plan
  def choose_offer
    @step = 1
    session[:step] = 1 unless session[:step]
    @plans = Plan.all
    @selected_plan = session[:plan_id]
    @choose_offer = true
    if request.post?
      if params[:plan_id]
        selected_plan = Plan.find(params[:plan_id])
        max_cart_allow = selected_plan.number_tipster + Subscription::MAX_ADDITIONAL_TIPSTERS
        if tipster_ids_in_cart.size > max_cart_allow
          session[:cart][:tipster_ids].clear
        end
        session[:plan_id] = selected_plan.id
        if selected_plan.free?
          session[:cart][:tipster_ids].clear
          redirect_to subscribe_personal_information_path and return
        else
          redirect_to subscribe_choose_tipster_path and return
        end
      end
    end
  end

  # listing all tipster
  def choose_tipster
    @step = 2
    session[:step] = 2 if session[:step] < 2
    @show_checkout_dialog = !!flash[:show_checkout_dialog]
    @selected_plan = session[:plan_id]
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all.order('position asc')
    @top_tipsters = Tipster.find_top_3_last_week(params)
    @sport = params["sport"]
    if params[:enable]

    end
  end

  # reg / input information
  def personal_information
    unless account_signed_in?
      redirect_to subscribe_account_url and return
    end
    if @select_plan
      if @select_plan.free?
        @step = 2
        session[:step] = 2 if (session[:step].nil? || session[:step] < 2)
      else
        @step = 3
        session[:step] = 3 if (session[:step].nil? || session[:step] < 3)
      end
      @account = current_account
      @subscriber = @account.rolable
      if request.post?
        @subscriber.validate_with_paid_account = !@select_plan.free?
        if @subscriber.update_attributes(profile_params)
          # Apply free plan
          if selected_plan.free?
            current_subscriber.apply_plan(@select_plan)
            empty_cart_session
            @subscriber.account.resend_confirmation_instructions unless @subscriber.account.confirmed?
          end
          redirect_to subscribe_shared_url
        end
      end
    else
      redirect_to pricing_url, notice: 'Please choose a plan'
    end
  end

  # shared & confirm if plan.free?
  def shared
    if @select_plan.free?
      @step = 3
      session[:step] = 3 if (session[:step].nil? || session[:step] < 3)
      else
      @step = 4
      session[:step] = 4 if (session[:step].nil? || session[:step] < 4)
    end
  end

  # select receiver methods, default true
  def receive_methods
    @step = 5
    session[:step] = 5 if (session[:step].nil? || session[:step] < 5)
    unless account_signed_in?
      redirect_to subscribe_personal_information_url and return
    end
    @account = current_account
    @subscriber = @account.rolable
    if request.post?
      @subscriber.update_receive_tips_method(params[:receive_tip_methods])
      session[:step] = 6
      redirect_to subscribe_payment_url
    end
  end

  # Calculating price and redirect to paypal
  # User is sign_in
  # Only apply for first time payment
  def payment
    @step = 6
    session[:step] = 6 if (session[:step].nil? || session[:step] < 6)
    @tipsters = Tipster.where(id: tipster_ids_in_cart)
    unless current_subscriber.subscription.present?
      @subscription = current_subscriber.build_subscription(plan_id: session[:plan_id])
    else
      @subscription = current_subscriber.subscription
    end
    @subscription.tipsters = @tipsters unless current_subscriber.already_has_subscription?
    @subscription.plan = @select_plan
    @subscription.using_coupon = true if using_coupon?
    @subscription.active = false
    @subscription.save

    if request.post?
      if params[:is_one_shoot] == "true"
        @subscription.update_attributes(is_one_shoot: true)
      elsif params[:is_one_shoot] == "false"
        @subscription.update_attributes(is_one_shoot: false)
      end
      if params[:method] == Payment::BY_PAYPAL
        @paypal = {
            amount: "%05.2f" % @subscription.calculator_price,
            currency: "EUR",
            item_number: current_subscriber.id,
            item_name: "TIPSTER HERO SUBSCRIPTION"
        }
        respond_to do |format|
          format.js { render 'paypalinit.js.haml' }
        end
      else
        puts "FRENCH BANK HERE"
      end
    end

  end

  def welcome
    @step = 4
  end


  private
  def load_subscribe_data
    @select_plan = selected_plan
  end

  def go_to_current_steps
    case session[:step]
      when 3
        redirect_to subscribe_personal_information_path
      when 4
        redirect_to subscribe_shared_path
      when 5
        redirect_to subscribe_receive_methods_path
      when 6
        redirect_to subscribe_payment_path
      else
        redirect_to subscribe_choose_offer_path
    end
  end

  def no_subscription_required
    if current_subscriber && current_subscriber.subscription && !current_subscriber.subscription.plan.free? && current_subscriber.subscription.active?
      redirect_to subscription_url
    end
  end

  def profile_params
    params.require(:subscriber).permit(
        :first_name, :last_name, :nickname, :gender, :receive_tip_methods, :birthday, :address, :city, :country, :zip_code, :mobile_phone,
        :telephone, :favorite_beting_website, :know_website_from, :secret_question, :answer_secret_question, :receive_info_from_partners,
        :humanizer_answer, :humanizer_question_id
    )
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