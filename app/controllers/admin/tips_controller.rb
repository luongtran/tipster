class Admin::TipsController < Admin::AdminBaseController
  before_action :authenticate_admin

  def index
    @tips = Tip.includes(:author, :sport, :match).order('created_at desc').limit(30)
    @sports = Sport.all
  end

  def show
    @tip = Tip.includes(:author, :sport, :match).find(params[:id])
  end

  def reject
    @tip = Tip.find(params[:id])
    if @tip.rejectable? && params[:reason].present?
      @tip.reject!(current_admin, params[:reason])
      redirect_to admin_tips_url, notice: 'The tip has been rejected.'
    else
      redirect_to admin_tips_url, alert: 'The tip cannot be rejected.'
    end
  rescue => e
    redirect_to admin_tips_url, alert: 'The tip cannot be rejected.'
  end

  # The tip and bet is valid and admin want to approve the tip
  def publish
    @tip = Tip.find(params[:id])
    if @tip.publishable?
      @tip.published!(current_admin)
      redirect_to admin_tips_url, notice: 'The tip has been published.'
    else
      redirect_to admin_tips_url, alert: 'The tip cannot be publish.'
    end
  end

  # The match ended and admin want to closed the tip
  # Substract or add money to tipster bankroll
  def finish
    @tip = Tip.find(params[:id])
    if @tip.finishable?
      @tip.finnish!(current_admin, (params[:result] == 'win'))
      redirect_to admin_tips_url, notice: 'The tip has been closed.'
    else
      redirect_to admin_tips_url, alert: 'The tip cannot be closed.'
    end
  end
end