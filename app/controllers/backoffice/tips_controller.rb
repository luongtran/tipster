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