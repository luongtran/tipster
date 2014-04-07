class Subscribers::ProfileController < ProfileController
  prepend_before_action :authenticate_subscriber

  protected
  def user_params
    params.require(:user).permit Subscriber::PROFILE_ATTRS
  end

  def after_update_profile_path
    my_profile_path
  end
end