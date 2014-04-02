class Subscribers::ProfileController < ProfileController
  prepend_before_action :authenticate_subscriber

  protected
  def user_params
    params.require(:user).permit Subscriber::PROFILE_ATTRS
  end

  def after_update_profile_path
    if current_subscriber.account.sign_in_count <= 1
      flash[:notice]= 'Please choose a plan'
      pricing_path
    else
      my_profile_path
    end
  end
end