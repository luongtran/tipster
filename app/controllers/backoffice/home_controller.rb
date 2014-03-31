class Backoffice::HomeController < ApplicationController
  before_action :authenticate_tipster, only: [:dashboard]

  def index
    redirect_to backoffice_dashboard_url if current_tipster
    if !!flash[:email]
      @email = flash[:email]
    end
  end

  def dashboard
    @tipster = current_tipster.prepare_statistics_data(params).initial_chart('profit')
    @recent_tips = current_tipster.tips.recent
    @subscribers = @tipster.followers
  end

  def my_statistics
    @monthly_statistics = current_tipster.get_monthly_statistics
  end
end