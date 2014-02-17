class SubscriptionController < ApplicationController
  def index
    @plan = Plan.all
  end

  def plan_select
    session[:plan_id] = params[:id]
    render 'tipster/top_tipster'
  end
end
