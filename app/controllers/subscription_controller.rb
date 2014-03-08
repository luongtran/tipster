class SubscriptionController < ApplicationController
  before_filter :authenticate_account!, only: [:show, :remove_inactive_tipster]

  def select_plan
    selected_plan = Plan.find(params[:id])
    max_cart_allow = selected_plan.number_tipster + Subscription::MAX_ADDTIONAL_TIPSTERS
    if tipster_ids_in_cart.size > max_cart_allow
      session[:cart][:tipster_ids].clear
    end
    session[:plan_id] = selected_plan.id
    if selected_plan.free?
      redirect_to subscribe_account_url
    else
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

end