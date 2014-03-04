class TipstersController < ApplicationController

  # GET /tipsters
  def index
    # params:
    # sport ['football', ...]
    # range ['last |1|3|6|12| months']  default: last_month
    # status [active|inactive]
    if flash[:show_checkout_dialog ]
      @show_checkout_dialog = true
    end
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all
  end

  def show
    @tipster = Tipster.find(params[:id])
  end
end
