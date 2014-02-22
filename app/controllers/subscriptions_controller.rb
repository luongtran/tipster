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

  def show
    @subscription = current_user.subscription
  end

  def remove_inactive_tipster
    @subscription = current_user.subscription
    @subscription.remove_tipster(params[:id])
    redirect_to action: 'show'
  end
end