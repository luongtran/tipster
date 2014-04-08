class Admin::TipsController < Admin::AdminBaseController
  before_action :authenticate_admin

  def index
    @tips = Tip.includes(:author, :sport, :match).order('created_at desc').limit(10)
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

  def publish
    @tip = Tip.find(params[:id])
    if @tip.publishalbe?
      @tip.published!(current_admin)
      redirect_to admin_tips_url, notice: 'The tip has been published.'
    else
      redirect_to admin_tips_url, alert: 'The tip cannot be publish.'
    end

    publish_admin_tip_path
  end
end