class Livescore::SportsController < Livescore::LivescoreBaseController

  def filter
    @sports = Sport.all
    current_sport = Sport.find_by!(code: params[:sport_code])
    competitions = current_sport.opta_competitions
  rescue ActiveRecord::RecordNotFound => e
    render_404
  end

  private

end