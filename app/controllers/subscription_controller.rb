class SubscriptionController < ApplicationController
  before_filter :authenticate_subscriber, only: [:show, :remove_inactive_tipster]

  def select_plan
    selected_plan = Plan.find(params[:id])
    max_cart_allow = selected_plan.number_tipster + Subscription::MAX_ADDITIONAL_TIPSTERS
    if tipster_ids_in_cart.size > max_cart_allow
      session[:cart][:tipster_ids].clear
    else
      if session[:failed_add_tipster_id]
        add_tipster_to_cart(session[:failed_add_tipster_id])
        session[:failed_add_tipster_id] = nil
      end
    end
    session[:plan_id] = selected_plan.id
    if selected_plan.free?
      redirect_to subscribe_account_url
    elsif params[:return_path]
      flash[:show_checkout_dialog] = true
      redirect_to subscribe_choose_offer_url
    else
      flash[:show_checkout_dialog] = true
      redirect_to tipsters_url
    end
  end

  def show
    @subscription = Subscription.includes(:plan).where(subscriber_id: current_subscriber.id).first
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

end