class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!, only: [:show]

  def plan_select
    session[:plan_id] = params[:id]
    redirect_to top_tipster_url
  end

  def show
    @subscription = current_user.subscription
  end
end