class Admin::ProfileController < ProfileController
  layout 'admin'
  USER_TYPE = Admin.name
  prepend_before_action :authenticate_admin

  protected
  def user_params
    params.require(:user).permit(:full_name)
  end

  def after_update_profile_path
    admin_dashboard_path
  end

  def current_user
    current_tipster
  end
end