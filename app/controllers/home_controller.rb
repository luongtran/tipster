class HomeController < ApplicationController
  def index
  end

  def pricing
    @plans = Plan.all
  end

end