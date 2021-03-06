class Admin::TipstersController < Admin::AdminBaseController
  before_action :authenticate_admin

  def index
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all.order('position asc')
  end

  def show
    @tipster = Tipster.includes(:account).find(params[:id])
  end
end