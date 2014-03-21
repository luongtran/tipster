class Backoffice::HomeController < ApplicationController
  before_action :tipster_required
  before_action :authenticate_account!, only: [:dashboard]

  def index
  end

  def dashboard
    @tipster = current_tipster
    @tipster.get_statistics
    @chart = Tipster.profit_chart_for_tipster(@tipster)
  end
end