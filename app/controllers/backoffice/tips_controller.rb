class Backoffice::TipsController < ApplicationController
  before_action :authenticate_tipster

  def my_tips
    @tips = Tip.by_author(current_tipster, params)
    @sports = current_tipster.sports
  end

  def new
    m = params[:m]
    prepare_data_for_new_tip
    @competitions = Competition.all
    if m == 'auto'
      @matches = Match.betable.includes(:competition, :sport)
      render 'create_auto'
    else
      @tip = current_tipster.tips.new
    end

  end

  def confirm
    @tip = Tip.new(tip_params)
  end

  def filter_matches
    prepare_data_for_new_tip
    @matches = Match.betable.load_data(params)
    success = true
    html = render_to_string(
        partial: 'backoffice/tips/available_matches_list',
        locals: {matches: @matches}
    ).html_safe
    render json: {
        success: success, html: html
    }
  end

  # GET
  # Find bets on the given match from Betclic XML feed
  def find_bets_on_match
    match_id = params[:match_id]
    match = Match.find_by(opta_match_id: match_id)

    success = true
    bets = []
    if match
      bets = Betclic.find_bets_on_match(match)
    else
      success = false
    end

    html = render_to_string(partial: 'backoffice/tips/bets_on_matches', locals: {match: match, bets: bets}).html_safe
    render json: {
        success: success, html: html
    }
  end

  def create
    @tip = current_tipster.tips.new(tip_params)
    if @tip.save
      redirect_to backoffice_tip_url(@tip), notice: I18n.t('tip.created_successfully')
    else
      prepare_data_for_new_tip
      render :new
    end
  end

  def show
    @tip = current_tipster.tips.find(params[:id])
  end

  private
  def prepare_data_for_new_tip
    @competitions = Competition.all
    @tipster_sports = current_tipster.sports
    @platforms = Platform.all
    @bet_types = BetType.all
  end

  def get_available_matches
    sports = current_tipster.sports
  end

  def tip_params
    #params.require(:tip).permit(Tip::CREATE_PARAMS)
    params.require(:tip).permit!
  end
end