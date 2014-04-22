class Backoffice::CreateTipController < Backoffice::BaseController
  def available_matches
    @bookmarker = Bookmarker.find_by!(code: params[:bookmarker])
    @matches = BookmarkerMatch.betable(params.merge(bookmarker: @bookmarker.code))
  rescue ActiveRecord::RecordNotFound => e
    redirect_to_root_path
  end

  def search_matches
    @bookmarker = Bookmarker.find_by!(code: params[:bookmarker])
    @matches = BookmarkerMatch.betable(params)
    html = render_to_string(
        partial: "backoffice/create_tip/bookmarker_matches_list",
        locals: {
            matches: @matches
        }
    )
    render json: {
        success: true,
        html: html
    }
  end

  def get_match_bets
    # Here find match by the 'id' column
    match = BookmarkerMatch.includes(:sport, :bookmarker).find_by!(id: params[:id])
    bets = match.find_bets
    success = true
    html = render_to_string(
        partial: "backoffice/create_tip/bookmarkers_bets/#{match.bookmarker_code}_bets",
        locals: {
            match: match,
            bets: bets
        }
    ).html_safe
    render json: {success: success, html: html}
  end

  # POST
  # Confirm select odds in automatic mode
  def confirm
    @match = BookmarkerMatch.includes(:sport, :bookmarker).find_by!(id: params[:tip][:match_id])
    @bet_type = @match.sport.bet_types.find_by!(code: params[:tip][:bet_type_code])
    tip_params = automatic_tip_params
    @tip = Tip.new(tip_params.merge(
                       bet_type_code: @bet_type.code,
                       sport_code: @match.sport.code
                   ))
    @tip.bookmarker_match_name = @match.name
    @tip.bookmarker_name = @match.bookmarker.name
  end

  def manual
  end

  def submit
    match = BookmarkerMatch.find_by(id: params[:match_id])
    @tip = Tip.create_from_bookmarker_match(current_tipster, match, tip_params)
    if @tip.save
      redirect_to backoffice_my_tips_url, notice: I18n.t('tip.created_successfully')
    else

    end
  end

  private
  def prepare_data_for_new_tip
    @competitions = Competition.includes(:sport).load
    @tipster_sports = current_tipster.sports
    @bet_types = BetType.all
    @bookmarkers = Bookmarker.all
  end

  def automatic_tip_params
    params.require(:tip).permit(Tip::AUTOMATIC_TIP_ATTRS)
  end
end