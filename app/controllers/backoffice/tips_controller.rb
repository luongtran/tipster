class Backoffice::TipsController < ApplicationController
  before_action :authenticate_tipster

  def my_tips
    @tips = Tip.by_author(current_tipster, params)
    @sports = current_tipster.sports
  end

  def new
    @tipster_sports = current_tipster.sports
    @areas = Area.all
    # Get all matches
    @all_matches = []
    start_date = DateTime.now + 1.hours
    end_date = 7.days.from_now.end_of_day.to_datetime
    log = Logger.new 'log/get_matches.log'
    %w(football basketball).each do |sport|
      # matches in 7 days
      fetcher = OptaSport::Fetcher.send(sport)
      if fetcher.respond_to? :get_matches
        result = fetcher.get_matches(
            id: '8318',
            type: 'season',
            start_date: start_date,
            end_date: end_date
        )
        @all_matches += result.all
      end

      log.info "\n Get matches: #{fetcher.last_url}"
    end

  end

  def submit
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


  def create
    @tip = current_tipster.tips.new(tip_params)
    if @tip.save
      redirect_to backoffice_tip_url(@tip), notice: I18n.t('tip.created_successfully')
    else
      prepare_data_for_sport(name: params[:sport])
      render :new
    end
  end

  def show
    @tip = current_tipster.tips.find(params[:id])
  end

  private
  def get_available_matches
    sports = current_tipster.sports
  end

  def prepare_data_for_sport(sport)
    @choosen_sport ||= current_tipster.sports.find_by!(sport)
    @bet_types = @choosen_sport.bet_types
    @events = Event.fetch(@choosen_sport.name)
    @platforms = Platform.all
  end

  def tip_params
    params.require(:tip).permit(Tip::CREATE_PARAMS)
  end
end