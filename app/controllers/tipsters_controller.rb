class TipstersController < ApplicationController
  before_action :find_tipster, only: [:show, :detail_statistics, :last_tips, :description, :profile]
  # GET /tipsters
  before_action :load_subscribe_data

  def index
    @show_checkout_dialog = !!flash[:show_checkout_dialog]
    @selected_plan = selected_plan

    @tipsters = Tipster.load_data(params)
    @top_3 = Tipster.find_tipsters_of_week(3)
    @sports = Sport.order('position asc')

    # TODO: Oh my God! How can I increase response time with these bellow lines
    # remember: this is a Controller not Model
    if current_subscriber && current_subscriber.has_active_subscription?
      @tipsters_in_subscription = current_subscriber.subscription.active_tipsters
    end
    if session[:add_tipster_id]
      @choose_tipster = Tipster.find session[:add_tipster_id]
    end
    if session[:failed_add_tipster_id]
      @choose_tipster = Tipster.find session[:failed_add_tipster_id]
    end
    if tipster_ids_in_cart.size == total_tipster
      if tipster_ids_in_cart.second
        @second_tipster = Tipster.find tipster_ids_in_cart.second
      end
      if tipster_ids_in_cart.third
        @third_tipster = Tipster.find tipster_ids_in_cart.third
      end
    else
      if total_tipster - tipster_ids_in_cart.size == 1
        @second_tipster = Tipster.find tipster_ids_in_cart.first if tipster_ids_in_cart.first
        @third_tipster = Tipster.find tipster_ids_in_cart.second if tipster_ids_in_cart.second
      elsif total_tipster - tipster_ids_in_cart.size == 2
        @second_tipster = current_subscriber.subscription.active_tipsters.second
        @third_tipster = Tipster.find tipster_ids_in_cart.first if tipster_ids_in_cart.first
      end
    end
    @tipster_first = session[:tipster_first].present?
    @total = total_tipster
  end

  def show
    @tipster = Tipster.includes(:statistics).find(params[:id]).
        prepare_statistics_data(params).initial_chart('profit')
    @range = 30.days.ago.beginning_of_day..DateTime.now
    @finished_tips = @tipster.finished_tips.in_range(30.days.ago.beginning_of_day..DateTime.now)
  end

  def detail_statistics
    # TODO: make the prepare function to be easier to pass parameter
    @tipster = @tipster.prepare_statistics_data({}, nil, true).initial_chart('all')
  end

  def last_tips
    @tipster_sports = @tipster.sports
    @tips = @tipster.tips.load_data(params)
  end

  def description
    @tipster
  end

  def profile
    @recent_tips = @tipster.recent_tips
  end

  private
  def find_tipster
    @tipster = Tipster.find(params[:id])
  end
end
