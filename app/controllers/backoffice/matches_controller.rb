class Backoffice::MatchesController < Backoffice::BaseController
  def show
    @match = Match.includes(:sport, :competition).find_by!(opta_match_id: params[:id].to_i)
  end

  def find_bets
    match = Match.includes(:sport).find_by(opta_match_id: params[:id])
    bets = match.find_bets(Bookmarker.first)
    success = true
    html = render_to_string(
        'bets_list',
        layout: false,
        locals: {match: match, bets: bets}
    ).html_safe
    render json: {success: success, html: html}
  end

  def search
    @matches = Match.betable.load_data(params)
    success = true
    html = render_to_string(
        partial: 'available_matches_list',
        locals: {
            matches: @matches,
            group_by: params[:group_by],
            mode: params[:mode]
        }
    ).html_safe
    render json: {
        success: success, html: html
    }
  end

  def available
    prepare_data
    @matches = Match.betable.load_data(sport: current_tipster.sport_codes)
    @mode = params[:mode].presence
    @mode ||= 'auto'
    if params[:mode] == 'manual'
      @tip = current_tipster.tips.new
      render 'manually_mode'
    else
      render 'automatically_mode'
    end
  end

  private
  def prepare_data
    @competitions = Competition.includes(:sport, :area).load
    @tipster_sports = current_tipster.sports
    @bookmarkers = Bookmarker.all
  end
end