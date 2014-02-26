class HomeController < ApplicationController
  def index
  end

  def pricing
    @plans = Plan.all
    if current_subscriber && current_subscriber.subscription && current_subscriber.subscription.active == true
      @selected_plan = current_subscriber.subscription.plan_id
    else
      @choosed_plan = session[:plan_id]
    end
  end

end