class TipstersController < ApplicationController

  # GET /tipsters
  def index
    # params:
    # sport ['football', ...]
    # range ['last |1|3|6|12| months']  default: last_month
    # status [active|inactive]
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all
  end

  def show

  end

  def top
    @tipster_ids_in_cart = tipster_ids_in_cart
    @tipster_ids_in_subscription = tipster_ids_in_subscription
    @tipsters = Tipster.order('id DESC').limit(50)
  end

  def free
    @tipsters = Tipster.order('id DESC').limit(50) #Where condition Free
    if current_user && current_user.subscription && current_user.subscription.active?
      @tipster_in_subscription = current_user.subscription.tipsters
    end
  end

end
