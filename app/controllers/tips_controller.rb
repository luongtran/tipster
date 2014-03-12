class TipsController < ApplicationController
  def index
    @tips = Tip.load_data(params)
    @sports = Sport.all
  end

  def last
    @tips = Tip.load_data(params)
    @sports = Sport.all
  end

  def show
    @tip = Tip.includes(:author, :sport).find(params[:id])
  end
end