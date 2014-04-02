class Admin::TipsController < Admin::AdminBaseController
  before_action :authenticate_admin
  def index
  end
end