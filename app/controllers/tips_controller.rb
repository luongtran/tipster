class TipsController < ApplicationController
  def index
    @tips = Tip.load_data(params)
    @sports = Sport.all
  end

  def last
    @tips =
        if request.query_parameters.empty?
          Tip.recent_finished(10)
        else
          Tip.load_data(params)
        end
    @sports = Sport.all
  end

  def show
    @tip = Tip.includes(:author, :sport).find(params[:id])
  end

end