class Admin::HomeController < Admin::AdminBaseController
  before_action :admin_required

  def index
  end

  def dashboard
  end
end