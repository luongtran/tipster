class SubscriptionController < ApplicationController
  def index
    @plan = Plan.all
  end

  def plan_select
    session[:plan_id] = params[:id]
    @tipster = Tipster.all
    render 'tipsters/top_tipster'
  end
end
