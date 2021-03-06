class SubscribeController < ApplicationController
  before_action :authenticate_subscriber, only: [:get_coupon_code]

  before_action :no_subscription_required, except: [:success]

  before_action :load_subscribe_data

  skip_before_filter :verify_authenticity_token, only: [:success]

  # Return from paypal
  def success
    flash[:alert] = I18n.t("paypal_pending_reasons.#{params[:pending_reason]}") if params[:pending_reason]
    empty_subscribe_session
    # Critial error when IPN not working !!!
    @payment = Payment.find_by_paykey(params[:paykey])
  end

  def get_coupon_code
    cc = CouponCode.create_for_user(current_subscriber, coupon_params[:source])
    if cc
      current_subscriber.build_subscription unless current_subscriber.subscription
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
    # FIXME: please constantize the step numbers!
    if current_subscriber && session[:step] && session[:step] > 2
      go_to_current_steps
    else
      redirect_to subscribe_personal_information_url
    end
  end

  def change_tipster
    # FIXME: please constantize the step numberss!
    @step = 2
    session[:old_id] = params[:old_id]
    redirect_to tipsters_path
  end

  def shopping_cart
    # FIXME: please constantize the step numbers!
    @step = 1
    session[:step] = 1 if (session[:step].nil? || session[:step] < 1)
    @tipsters = Tipster.where(id: tipster_ids_in_cart)
  end

  # reg / input information
  def personal_information
    # FIXME: please constantize the step numbers!
    if selected_plan
      if selected_plan.free?
        @step = 1
        session[:step] = 1 if (session[:step].nil? || session[:step] < 1)
      else
        @step = 2
        session[:step] = 2 if (session[:step].nil? || session[:step] < 2)
      end

      if current_subscriber
        @subscriber = current_subscriber
      else
        @subscriber ||= Subscriber.new
        @account = @subscriber.build_account
        @account2 ||= Account.new
      end
      if request.post?
        if params[:i_token] == 'DdM26nAJNTyuaMRXjnrF8vP8'
          if current_subscriber
            current_subscriber.validate_with_paid_account = !selected_plan.free?
            if current_subscriber.update_attributes(profile_params)
              if selected_plan.free?
                current_subscriber.apply_plan(selected_plan)
                empty_cart_session
                @subscriber.account.resend_confirmation_instructions unless @subscriber.account.confirmed?
              end
              redirect_to subscribe_shared_url
            end
          else
            s_params = subscriber_params
            account_params = s_params.delete :account
            @subscriber = Subscriber.new(s_params)
            @subscriber.validate_with_paid_account = !selected_plan.free?
            @account = Account.new(account_params)

            valid = @subscriber.valid?
            valid = @account.valid? && valid
            if valid
              @subscriber.save
              @account.rolable = @subscriber
              @account.save
              sign_in @account
              redirect_to subscribe_shared_url
            end
          end
          #  Sign in
        elsif params[:i_token] == 'KCWUzKdK7b2s9CXBDyKjFTcG'
          @account2 = Account.find_by_email(params[:account][:email])
          if @account2 && @account2.valid_password?(params[:account][:password])
            sign_in @account2
            @subscriber = @account2.rolable
            if @subscriber.valid_profile?
              redirect_to subscribe_shared_url
            else
              flash[:notice] = "Please update your profile"
            end
          else
            @error = true
            @account2 ||= Account.new
          end
        else
          render_404
        end
      else
      end
    else
      redirect_to pricing_url, notice: 'Please choose a plan'
    end
  end

  # shared & confirm if plan.free?
  def shared
    # FIXME: please constantize the step numbers!
    if selected_plan.free?
      @step = 2
      session[:step] = 2 if (session[:step].nil? || session[:step] < 2)
    else
      @step = 3
      session[:step] = 3 if (session[:step].nil? || session[:step] < 3)
    end
  end

  # select receiver methods, default true
  def receive_methods
    # FIXME: please constantize the step numbers!
    @step = 4
    session[:step] = 4 if (session[:step].nil? || session[:step] < 4)
    unless account_signed_in?
      redirect_to subscribe_personal_information_url and return
    end
    @account = current_account
    @subscriber = @account.rolable
    if request.post?
      @subscriber.update_receive_tips_method(params[:receive_tip_methods])
      session[:step] = 5
      redirect_to subscribe_payment_url
    end
  end

  # Calculating price and redirect to paypal
  # User is sign_in
  # Only apply for first time payment
  def payment
    # FIXME: please constantize the step numbers!
    @step = 5
    session[:step] = 5 if (session[:step].nil? || session[:step] < 5)
    @tipsters = Tipster.where(id: tipster_ids_in_cart)
    unless current_subscriber.subscription.present?
      @subscription = current_subscriber.build_subscription(plan_id: session[:plan_id])
    else
      @subscription = current_subscriber.subscription
    end
    @subscription.tipsters = @tipsters unless current_subscriber.already_has_subscription?
    @subscription.plan = selected_plan
    @subscription.using_coupon = true if using_coupon?
    @subscription.active = false
    @subscription.save
    @subscription.set_primary(tipster_ids_in_cart.first.to_i)

    if request.post?
      if params[:is_one_shoot] == "true"
        @subscription.update_attributes(is_one_shoot: true)
      elsif params[:is_one_shoot] == "false"
        @subscription.update_attributes(is_one_shoot: false)
      end
      if params[:method] == Payment::BY_PAYPAL
        ret = @subscription.generate_paykey
        if ret[:success]
          paykey = ret[:paykey]
          @paypal = {
              amount: "%05.2f" % @subscription.calculator_price,
              currency: "EUR",
              item_number: current_subscriber.id,
              paykey: paykey,
              item_name: "TIPSTER HERO SUBSCRIPTION"
          }
          respond_to do |format|
            format.js { render 'paypalinit.js.haml' }
          end
        else
          logger = Logger.new('log/payment_error.log')
          logger.info("CREATE PAYKEY FAILER")
          logger.info(ret[:message])
          render js: 'window.location = '/''
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
  def subscriber_params
    params.require(:subscriber).permit(Subscriber::PROFILE_ATTRS << {account: [:email, :password, :password_confirmation]})
  end

  def go_to_current_steps
    # FIXME: please constantize the step number!
    case session[:step]
      when 1
        redirect_to subscribe_shopping_cart_path
      when 2
        redirect_to subscribe_personal_information_path
      when 3
        redirect_to subscribe_shared_path
      when 4
        redirect_to subscribe_receive_methods_path
      when 5
        redirect_to subscribe_payment_path
      else
        redirect_to pricing_path
    end
  end

  def no_subscription_required
    # FIXME: please constantize the step number!
    if current_subscriber && current_subscriber.subscription && !current_subscriber.subscription.try(:plan).try(:free?) && current_subscriber.subscription.active?
      redirect_to add_tipster_subscription_path
    end
  end

  def profile_params
    params.require(:subscriber).permit((Subscriber::PROFILE_ATTRS << :account))
  end

  def account_params
    params.require(:subscriber).require(:account).permit(:email, :password, :password_confirmation)
  end

  def coupon_params
    params.permit!
  end

  def ready_to_payment
    checker =
        if !current_subscriber
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