class TipsController < ApplicationController
  def index
    @tips = Tip.all
  end

  def show

  end
end