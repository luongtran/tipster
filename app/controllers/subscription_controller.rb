class SubscriptionController < ApplicationController
  before_filter :authenticate_subscriber, only: [:show, :remove_inactive_tipster, :set_primary]

  def select_plan
    selected_plan = Plan.find(params[:id])
    if selected_plan
      session[:plan_id] = selected_plan.id
      if selected_plan.free?
        empty_cart_session
        redirect_to subscribe_personal_information_url and return
      else
        if session[:failed_add_tipster_id]
          tipster_id = session[:failed_add_tipster_id]
          if Tipster.exists?(tipster_id)
            initial_cart_session if session[:cart].nil?
            unless tipster_ids_in_cart.include? tipster_id
              add_tipster_to_cart(tipster_id)
              session[:add_tipster_id] = tipster_id
            end
          end
          session[:failed_add_tipster_id] = nil
        end
        flash[:show_checkout_dialog] = true
        if tipster_ids_in_cart.size == 0
          redirect_to pricing_path
        else
          redirect_to tipsters_path
        end
      end
    else
      render_404
    end
  end

  def show
    #@subscription = Subscription.includes(:plan).where(subscriber_id: current_subscriber.id).first
    @subscription = current_subscriber.subscription
  end

  def remove_inactive_tipster
    @subscription = current_subscriber.subscription
    if @subscription.can_change_tipster?
      @subscription.remove_tipster(params[:id])
      redirect_to action: 'show', notice: 'Tipster unfollow'
    else
      redirect_to action: 'show', notice: "You can change your follow tipster on day #{current_subscription.active_at.strftime('%d')}  of the month"
    end
  end

  def add_tipster_to_current_subscription

  end

  # Adding tipster to current subscription
  # Validate current subscription is active & select tipster < limit
  def add_tipster
    current_subscription = current_subscriber.subscription
    select_plan = current_subscription.plan
    select_tipsters = Tipster.where(id: tipster_ids_in_cart)
    if request.post?
      if current_subscription.active? && current_subscription.able_to_add_more_tipsters?(select_tipsters.size)
        current_subscription.insert_tipster(select_tipsters)
        ret = current_subscription.generate_paykey
        if ret[:success]
          paykey = ret[:paykey]
          @paypal = {
              amount: "%05.2f" % current_subscription.need_to_paid,
              currency: "EUR",
              item_number: current_subscriber.id,
              paykey: paykey,
              item_name: "TIPSTER HERO ADDITION TIPSTER"
          }
          respond_to do |format|
            format.js { render 'paypalinit.js.haml' }
          end
        else
          logger = Logger.new('log/payment_error.log')
          logger.info("CREATE PAYKEY FAILER")
          logger.info(ret[:message])
          flash[:alert] = "You've already reached subscription limit"
          render js: 'window.location = "/subscription"'
        end
      else
        flash[:alert] = "Over limit tipsters!"
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

  def set_primary
    @subscription = current_subscriber.subscription
    response = @subscription.set_primary(params[:id])
    if response.success
      render json: {success: true}
    else
      render json: {success: false, error: response.error}
    end
  end

  # Change subscription plan
  def change_plan
  end

end