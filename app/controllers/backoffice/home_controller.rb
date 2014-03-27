class Backoffice::HomeController < ApplicationController
  before_action :authenticate_tipster, only: [:dashboard]

  def index
    redirect_to backoffice_dashboard_url if current_tipster
    if !!flash[:email]
      @email = flash[:email]
    end
  end

  def dashboard
    @tipster = current_tipster.get_statistics
    @recent_tips = @tipster.tips.recent
    @subscribers = @tipster.followers
    @chart = Tipster.profit_chart_for_tipster(@tipster)
  end

  def my_statistics
    @monthly_statistics = current_tipster.get_monthly_statistics
  end
end