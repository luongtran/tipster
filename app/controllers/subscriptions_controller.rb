class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!, only: [:show,:remove_inactive_tipster]

  def select_plan
    selected_plan = Plan.find(params[:id])
    session[:plan_id] = selected_plan.id
    if selected_plan.free?
      redirect_to subscribe_choose_offer_url
    else
      redirect_to top_tipsters_url
    end
  end
  def select_free_plan
    session[:free_plan] = true
    redirect_to free_tipsters_path
  end

  def show
    @subscription = current_user.subscription
  end

  def remove_inactive_tipster
    @subscription = current_user.subscription
    if @subscription.can_change_tipster?
      @subscription.remove_tipster(params[:id])
      redirect_to subscription_path,:notice => "Tipster unfollow"
    else
      redirect_to subscription_path,notice: "You can change your follow tipster on day #{current_subscription.active_date.strftime('%d')}  of the month" and return
    end
  end
end