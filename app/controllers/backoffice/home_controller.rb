class Backoffice::HomeController < Backoffice::BaseController
  before_action :authenticate_tipster, only: [:dashboard]

  def index
    redirect_to backoffice_dashboard_url if current_tipster
    if !!flash[:email]
      @email = flash[:email]
    end
  end

  def dashboard
    @tipster = current_tipster.prepare_statistics_data(params)
    @recent_tips = current_tipster.tips.recent
    @recent_activities = TipJournal.recent_activities_on_tips(@recent_tips.map { |tip| tip.id })
    @subscribers = @tipster.followers
  end

  def my_statistics
    @tipster = current_tipster.prepare_statistics_data(params, true)
  end
end