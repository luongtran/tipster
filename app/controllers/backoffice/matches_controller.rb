class Backoffice::MatchesController < Backoffice::BaseController
  before_filter :authenticate_tipster

  def show
    @match = Match.includes(:sport, :competition).find_by!(uid: params[:id].to_i)
    @bets = @match.find_bets
  end

  def find_bets
    match = Match.includes(:sport).find_by(uid: params[:id])
    bets = match.find_bets
    success = true
    html = render_to_string(
        'bets_list',
        layout: false,
        locals: {match: match, bets: bets}
    ).html_safe
    render json: {success: success, html: html}
  end

  def search
    edited_params = params

    unless params[:sport].present?
      edited_params = params.merge(sport: current_tipster.sport_codes)
    end

    @matches = Match.available_to_create_tips params.merge(edited_params)
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
    @matches = Match.available_to_create_tips(sport: current_tipster.sport_codes)
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
    @competitions = Competition.includes(:sport).load
    @tipster_sports = current_tipster.sports
    @bookmarkers = Bookmarker.all
  end
end