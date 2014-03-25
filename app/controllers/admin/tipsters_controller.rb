class Admin::TipstersController < Admin::AdminBaseController
  def index
    @tipsters = Tipster.load_data(params)
    @sports = Sport.all.order('position asc')
  end
end