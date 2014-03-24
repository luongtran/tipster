class Backoffice::ProfileController < ProfileController
  before_action :authenticate_tipster, :prepare_user_data

  def change_avatar
    prepare_user_data
    if @user.update_attribute(:avatar, params.require(:user).permit(:avatar, :avatar_cache)[:avatar])
      flash[:notice] = I18n.t('user.avatar_update_successully')
      redirect_to after_update_profile_path
    else
      flash[:alert] = I18n.t('user.account_update_failed')
      render :show
    end
  end

  def update_description
    current_tipster.update_description(params[:user][:description])
    redirect_to after_update_profile_path, notice: I18n.t('user.account_update_successully')
  end

  protected
  def user_params
    params.require(:user).permit Tipster::PROFILE_ATTRS
  end

  def current_user
    current_tipster
  end

  def after_update_profile_path
    backoffice_my_profile_path
  end
end
