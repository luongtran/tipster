class Backoffice::TipsController < ApplicationController
  before_action :authenticate_account!, :tipster_required

  def my_tips
    @tips = Tip.by_author(current_tipster, params)
    @sports = current_tipster.sports
  end

  def new
    if params[:sport].present?
      prepare_data_for_sport(name: params[:sport])
      @tip = current_tipster.tips.new(sport: @choosen_sport)
    else
      @tipster_sports = current_tipster.sports
      render 'backoffice/tips/choose_sport'
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