class TipsController < ApplicationController
  def index
    @tips = Tip.includes(:author).limit(30)
    @sports = Sport.all
  end

  def show
    @tip = Tip.includes(:author, :sport).find(params[:id])
  end
end