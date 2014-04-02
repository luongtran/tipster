class Admin::HomeController < Admin::AdminBaseController
  def index
    if current_admin
      redirect_to admin_dashboard_url
    end
  end

  def dashboard
  end
end