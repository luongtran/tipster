class Backoffice::TipsController < ApplicationController
  before_action :authenticate_account!, :tipster_required

  def my_tips
    @tips = current_tipster.tips
    @sports = current_tipster.sports
  end

  def new
    prepare_events
    @tip = current_tipster.tips.new
    #Need get information about live match here
  end

  def create
    @tip = current_tipster.tips.new(tip_params)
    if @tip.save
      redirect_to backoffice_tip_url(@tip), notice: I18n.t('tip.created_successfully')
    else
      prepare_events
      render :new
    end
  end

  def show
    @tip = current_tipster.tips.find(params[:id])
  end

  private
  def prepare_events
    @events = Event.fetch
  end

  def tip_params
    params.require(:tip).permit(:event, :platform, :bet_type, :odds, :selection, :advice, :stake, :amount,:sport_id)
  end
end