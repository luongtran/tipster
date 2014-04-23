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

  # POST /backoffice/create-tip/confirm
  # Submit tip form from automatically mode
  def confirm
    tip_params = automatic_tip_params
    @match = BookmarkerMatch.includes(:sport, :bookmarker).find_by!(id: params[:tip][:match_id])
    @tip = Tip.inititalize_from_bookmarker_match(current_tipster, @match, tip_params)
    if @tip.save
      redirect_to backoffice_my_tips_url, notice: I18n.t('tip.created_successfully')
    end
  rescue ActiveRecord::RecordNotFound => e
    redirect_to_root_path
  end


  # GET|POST /backoffice/create-tip/manual
  # Submit tip form from manually mode
  def manual
    if request.get?
      prepare_data_for_new_tip
      @tip = current_tipster.tips.new
      @manual_match = ManualMatch.new
    else
      tip_params = manual_tip_params
      @manual_match = ManualMatch.new(tip_params.delete(:manual_match))
      @tip = Tip.create_with_manual_match(current_tipster, @manual_match, tip_params)
      if @tip.persisted?
        redirect_to backoffice_my_tips_url, notice: I18n.t('tip.created_successfully')
      else
        prepare_data_for_new_tip
      end
    end
  end

  def match_details
    @match = BookmarkerMatch.includes(:sport, :bookmarker).find(params[:id])
    @bets = @match.find_bets
  end

  private
  def prepare_data_for_new_tip
    @tipster_sports = current_tipster.sports
    @bet_types = BetType.where(sport_code: @tipster_sports.pluck(:code))
    @bookmarkers = Bookmarker.all
  end

  def automatic_tip_params
    params.require(:tip).permit(Tip::AUTOMATIC_TIP_ATTRS)
  end

  def manual_tip_params
    params.require(:tip).permit(Tip::MANUAL_TIP_PARAMS)
  end
end