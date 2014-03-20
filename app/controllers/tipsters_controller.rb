class TipstersController < ApplicationController
  before_action :find_tipster, only: [:show, :detail_statistics, :last_tips, :description, :profile]
  # GET /tipsters
  def index
    @show_checkout_dialog = !!flash[:show_checkout_dialog]
    @selected_plan = selected_plan
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all.order('position asc')
    @top_tipsters = Tipster.find_top_3_last_week(params)
    if current_subscriber && current_subscriber.has_active_subscription?
      @tipsters_in_subscription = current_subscriber.subscription.active_tipsters
    end
    if session[:add_tipster_id]
      @choose_tipster = Tipster.find session[:add_tipster_id]
      session[:add_tipster_id] = nil
    end
    if session[:failed_add_tipster_id]
      @choose_tipster = Tipster.find session[:failed_add_tipster_id]
    end
    if tipster_ids_in_cart.second
      @second_tipster = Tipster.find tipster_ids_in_cart.second
    end
    if tipster_ids_in_cart.third
      @third_tipster = Tipster.find tipster_ids_in_cart.third
    end
    @tipster_first = session[:tipster_first].present?
  end

  def top_three
    tipsters = Tipster.find_top_3_last_week(params)
    render partial: 'top_three', locals: {tipsters: tipsters}
  end

  def show
    @tipster.get_statistics(params)
    @chart = Tipster.profit_chart_for_tipster(@tipster)
  end

  def detail_statistics
    @tipster.get_statistics(ranking: Tipster::OVERALL)
  end

  def last_tips
    @tipster.get_statistics(ranking: Tipster::OVERALL)
  end

  def description
    @tipster.get_statistics(ranking: Tipster::OVERALL)
  end

  def profile
    @recent_tips = @tipster.recent_tips
  end

  private
  def find_tipster
    @tipster = Tipster.find(params[:id])
  end
end
