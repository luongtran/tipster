class Backoffice::ProfileController < ProfileController
  before_action :authenticate_account!, :tipster_required

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

  def crop_avatar
    prepare_user_data
    if @user.update_attributes(params.require(:user).permit(:crop_x, :crop_y, :crop_h, :crop_w))
      flash[:notice] = I18n.t('user.update_avatar')
      redirect_to after_update_profile_path
    else
      flash[:alert] = @user.errors.messages #I18n.t('user.account_update_failed')
      redirect_to after_update_profile_path
    end
  end

  protected
  def user_params
    params.require(:user).permit(
        :display_name,
        :full_name
    )
  end

  def current_user
    current_tipster
  end

  def after_update_profile_path
    backoffice_my_profile_path
  end
end
