class Admin::HomeController < Admin::AdminBaseController
  before_action :authenticate_admin, only: [:dashboard]

  def index
    if current_admin
      redirect_to admin_dashboard_url
    end
  end

  def dashboard
    @tip_journals = TipJournal.includes(:author, tip: [:match]).order('created_at desc')
  end
end