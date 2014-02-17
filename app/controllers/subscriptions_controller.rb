class SubscriptionsController < ApplicationController

  def plan_select
    session[:plan_id] = params[:id]
    @tipsters = Tipster.all
    render 'tipsters/top_tipster'
  end
end
