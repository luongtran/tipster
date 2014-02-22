class HomeController < ApplicationController
  def index
  end

  def pricing
    @plans = Plan.all
    if current_user && current_user.subscription && current_user.subscription.payments.present? && current_user.subscription.payments.last.payment_status == "Completed"
      @selected_plan = current_user.subscription.plan_id
    end
  end

end