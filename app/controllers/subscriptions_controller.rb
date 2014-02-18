class SubscriptionsController < ApplicationController

  def plan_select
    session[:plan_id] = params[:id]
    redirect_to top_tipster_url
  end
end