class Backoffice::TipsController < ApplicationController
  before_filter :authenticate_tipster!

  def index

  end

  def new
    @tip = Tip.new
  end

  def create
    @tip = current_tipster.tips.new(tip_params)
    if @tip.save
      redirect_to backoffice_tip_url(@tip), notice: 'Tip created successfully!'
    else
      render :new
    end
  end

  def show
    @tip = current_tipster.tips.find(params[:id])
  end

  private

  def tip_params
    params.require(:tip).permit(:event, :platform, :bet_type, :odds, :selection, :advice, :stake, :amount)
  end
end