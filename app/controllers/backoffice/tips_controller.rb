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
      # Get all available matches
      @matches = Match.betable.includes(:competition, :sport)

      render 'available_matches'
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
    html = render_to_string(partial: 'backoffice/tips/available_matches_list', locals: {matches: @matches}).html_safe
    render json: {
        success: success, html: html
    }
  end

  def get_areas
    sport_id = params[:sport_id]
    @areas = Area.all
    respond_to do |f|
      f.json do
        render json: {
            areas: @areas.map do |area|
              {
                  id: area.area_id,
                  name: area.name,
                  url: get_competitions_backoffice_tips_path(area_id: area.area_id)}
            end
        }
      end
    end
  end

  def get_competitions
    # Current Premier League session id : 8318
    # &start_date=2014-03-20%2000:00:00&end_date=2014-04-27%2023:59:59
    area_id = params[:area_id]
    @competitions = Competition.where(area_id: area_id)
    respond_to do |f|
      f.json do
        render json: {
            competitions: @competitions.map { |compt| {id: compt.competition_id, name: compt.name} }
        }
      end
    end
  end

  def get_matches
    log = Logger.new 'log/get_matches.log'
    sport_id = params[:sport]
    area_id = params[:area]
    competition_id = params[:competition]
    sport_name = Sport.find_by(id: sport_id).name
    fetcher = OptaSport::Fetcher.send(sport_name)

    result = fetcher.get_matches(
        id: area_id,
        type: 'area',
        start_date: Date.today.beginning_of_day.to_datetime,
        end_date: Date.today.end_of_day.to_datetime,
    )
    log.info result.class
    log.info "Last url:" + fetcher.last_url

    respond_to do |f|
      f.json do
        render json: {
        }
      end
    end
  end

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