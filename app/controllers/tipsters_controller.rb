class TipstersController < ApplicationController
  def index

  end

  def show

  end

  def top
    @tipster_ids_in_cart = tipster_ids_in_cart
    if params[:period]
      @tipsters = Tipster.order('name DESC').limit(30)
    else
      @tipsters = Tipster.order('id DESC').limit(50)
    end
    if current_user && current_user.subscriptions && current_user.subscriptions.payments.present? && current_user.subscription.payments.last.payment_status == "Completed"
      @tipster_in_subscription = current_user.subscription.tipsters
    end
  end

end
