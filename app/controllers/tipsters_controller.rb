class TipstersController < ApplicationController

  # GET /tipsters
  def index
    # params:
    # sport ['football', ...]
    # range ['last |1|3|6|12| months']  default: last_month
    # status [active|inactive]
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all
  end

  def show
    @tipster = Tipster.find params[:id]
  end
end
