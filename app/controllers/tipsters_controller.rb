class TipstersController < ApplicationController

  # GET /tipsters
  def index
    # params:
    # sport ['football', ...]
    # rank ['last |1|3|6|12| months']
    @tipsters = Tipster.all

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
    if current_user && current_user.subscription.payment_completed?
      @tipster_in_subscription = current_user.subscription.tipsters
    end
  end

end
