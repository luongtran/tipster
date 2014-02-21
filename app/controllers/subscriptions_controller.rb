class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!, only: [:show]

  def select_plan
    selected_plan = Plan.find(params[:id])
    session[:plan_id] = selected_plan.id
    if selected_plan.free?
      redirect_to subscribe_choose_offer_url
    else
      redirect_to top_tipster_url
    end
  end

  def show
    @subscription = current_user.subscription
  end
end