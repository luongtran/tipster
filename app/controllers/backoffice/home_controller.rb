class Backoffice::HomeController < ApplicationController
  before_action :authenticate_tipster, only: [:dashboard]

  def index
    redirect_to backoffice_dashboard_url if current_tipster
  end

  def dashboard
    @tipster = current_tipster.get_statistics

    @recent_tips = @tipster.tips.recent
    @chart = Tipster.profit_chart_for_tipster(@tipster)
  end
end