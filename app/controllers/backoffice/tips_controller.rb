class Backoffice::TipsController < Backoffice::BaseController
  before_action :authenticate_tipster

  def my_tips
    @tips = Tip.by_author(current_tipster, params)
    @tipster_sports = current_tipster.sports
  end

  def new
    # FIXME: the code bellow has wrote at 18h :))
    @match = Match.includes(sport: [:bet_types]).find_by(opta_match_id: params[:match].to_i)
    @bet_types = @match.sport.bet_types
    prepare_data_for_new_tip
    @tip = current_tipster.tips.new(
        match_id: @match.opta_match_id,
        sport_code: @match.sport_code
    )
  end

  def available_matches
    prepare_data_for_new_tip
    @matches = Match.betable.load_data(sport: current_tipster.sport_codes)
    if params[:mode] == 'manual'
      @tip = current_tipster.tips.new
      render 'manually_mode'
    else
      render 'automatically_mode'
    end
  end

  def confirm
    # FIXME: the code bellow has wrote at 18h :))
    @match = Match.includes(sport: [:bet_types]).find_by!(opta_match_id: params[:tip][:match_id])
    @bet_type = @match.sport.bet_types.find_by!(code: params[:tip][:bet_type_code])
    bookmarker = Bookmarker.find_by!(code: 'betclic')
    @tip = Tip.new(tip_params.merge(
                       bet_type_code: @bet_type.code,
                       sport_code: @match.sport.code,
                       bookmarker_code: bookmarker.code
                   ))
    #rescue ActiveRecord::RecordNotFound => e
    #  redirect_to :back, alert: 'Request is invalid'
  end

  def submit
  end

  # POST from AJAX
  def filter_matches
    # FIXME: the code bellow has wrote at 18h :))
    params_x = params
    unless params_x[:sport].present?
      params_x = params_x.merge(sport: current_tipster.sport_ids)
    end
    @matches = Match.betable.load_data(params_x)
    success = true
    html = render_to_string(
        partial: 'backoffice/tips/available_matches_list',
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

  # GET
  # Find bets on the given match from Betclic XML feed
  def find_bets_on_match

  end

  def create
    @tip = current_tipster.tips.new(tip_params)
    if @tip.save
      redirect_to backoffice_my_tips_url, notice: I18n.t('tip.created_successfully')
    else
      if params[:act] == 'confirm'
        @tip.match_name = @tip.match.name
        @tip.bet_type_name = @tip.bet_type.name
        render 'confirm'
      else
        @bet_types = @tip.match.sport.bet_types
        prepare_data_for_new_tip
        render 'new'
      end
    end

  end

  def show
    @tip = current_tipster.tips.includes(:match, :bet_type, :sport).find(params[:id])
  end

  private
  def prepare_data_for_new_tip
    @competitions = Competition.includes(:sport, :area).load
    @tipster_sports = current_tipster.sports
    @bookmarkers = Bookmarker.all
  end

  def get_available_matches
    sports = current_tipster.sports
  end

  def tip_params
    #params.require(:tip).permit(Tip::CREATE_PARAMS)
    params.require(:tip).permit!
  end
end