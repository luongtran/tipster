class TipstersController < ApplicationController

  # GET /tipsters
  def index
    @show_checkout_dialog = !!flash[:show_checkout_dialog]

    @select_plan = selected_plan

    @tipsters = Tipster.load_data(params)

    @sports = Sport.all.order('position asc')

    @top_tipsters = Tipster.find_top_3_last_week(params)

    if current_subscriber && current_subscriber.has_active_subscription?
      @tipsters_in_subscription = current_subscriber.subscription.active_tipsters
    end

  end

  def fetch
    @show_checkout_dialog = !!flash[:show_checkout_dialog]

    @select_plan = selected_plan

    @tipsters = Tipster.load_data(params)

    @sports = Sport.all.order('position asc')

    @top_tipsters = Tipster.find_top_3_last_week(params)

    if current_subscriber && current_subscriber.has_active_subscription?
      @tipsters_in_subscription = current_subscriber.subscription.active_tipsters
    end
  end

  def top_three
    tipsters = Tipster.find_top_3_last_week(params)
    render partial: 'top_three', locals: {tipsters: tipsters}
  end

  def show
    @tipster = Tipster.find(params[:id])
    @tipster.get_statistics
    @recent_tips = @tipster.recent_tips
  end

  def profile
    @tipster = Tipster.find(params[:id])
    @recent_tips = @tipster.recent_tips
  end
end
