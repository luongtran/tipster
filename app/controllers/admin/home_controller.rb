class Admin::HomeController < Admin::AdminBaseController
  before_action :authenticate_admin, only: [:dashboard]

  def index
    if current_admin
      redirect_to admin_dashboard_url
    end
  end

  def dashboard
    @recent_activities = TipJournal.includes(:author, tip: [:match]).order('created_at desc').limit(7)
  end
end