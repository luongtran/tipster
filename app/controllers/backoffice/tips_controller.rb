class Backoffice::TipsController < Backoffice::BaseController
  before_action :authenticate_tipster

  def my_tips
    @tips =
        if request.query_parameters.empty?
          current_tipster.tips.recent(10)
        else
          Tip.by_author(current_tipster, params)
        end
    @tipster_sports = current_tipster.sports
  end

  # GET|POST /backoffice/tips/create_manual
  def create_manual
    if request.get?
      prepare_data_for_new_tip
      @match = Match.new
      @tip = current_tipster.tips.new
    else

    end
  end

  # GET /backoffice/tips/available_bets
  def available_bets
    if request.xhr?
      bookmarker = Bookmarker.find_by!(code: params[:bookmarker_code])
      matches = BookmarkerMatch.betable(params)
      html = render_to_string(
          partial: "backoffice/tips/bookmarkers/#{bookmarker.code}_matches",
          locals: {
              matches: matches,
          }
      ).html_safe
      render json: {
          success: true, html: html
      }
    else
      prepare_data_for_new_tip
      @matches = BookmarkerMatch.betable
    end
  end

  def confirm
    # FIXME: the code bellow has wrote at 18h :))
    @match = Match.includes(sport: [:bet_types]).find_by!(uid: params[:tip][:match_uid])
    @bet_type = @match.sport.bet_types.find_by!(code: params[:tip][:bet_type_code])


    bookmarker = Bookmarker.find_by!(code: params[:tip][:bookmarker_code])
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
    @tip = current_tipster.tips.includes(:bet_type, :sport).find(params[:id])
  end

  private
  def prepare_data_for_new_tip
    @competitions = Competition.includes(:sport).load
    @tipster_sports = current_tipster.sports
    @bet_types = BetType.all
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