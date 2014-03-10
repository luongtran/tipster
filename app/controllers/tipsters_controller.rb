class TipstersController < ApplicationController

  # GET /tipsters
  def index
    @show_checkout_dialog = !!flash[:show_checkout_dialog]
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all.order('position asc')
    @top_tipster = @tipsters.first(3) #just for test
    if current_subscriber && current_subscriber.has_active_subscription?
      @tipsters_in_subscription = current_subscriber.subscription.active_tipsters
    end
  end

  def show
    @tipster = Tipster.find(params[:id])
    @recent_tips = @tipster.recent_tips
  end
end
