class SubscribeController < ApplicationController
  before_action :authenticate_account!, only: [:get_coupon_code]
  before_action :no_subscription_required,except: [:success]
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
      @select_plan = selected_plan
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
    @select_plan = selected_plan
    if @select_plan
      @account = current_account
      @subscriber = @account.rolable
      if request.post?
        @subscriber.validate_with_paid_account = !@select_plan.free?
        if @subscriber.update_attributes(profile_params)
          # Apply free plan
          if selected_plan.free?
            current_subscriber.apply_plan(@select_plan)
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
    @subscription.plan = @select_plan
    @subscription.using_coupon = true if using_coupon?
    @subscription.active = false
    @subscription.save

    if request.post?
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
  end

  private
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