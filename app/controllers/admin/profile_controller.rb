class Admin::ProfileController < Admin::AdminBaseController
  before_action :authenticate_admin

  def show
  end
end