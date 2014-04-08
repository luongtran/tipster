class Admin::HomeController < Admin::AdminBaseController
  def index
    if current_admin
      redirect_to admin_dashboard_url
    end
  end

  def dashboard
    @tip_journals = TipJournal.includes(:author, :tip).order('created_at desc')
  end
end