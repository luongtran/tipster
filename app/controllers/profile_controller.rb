class ProfileController < ApplicationController
  before_action :authenticate_account!, :subscriber_required
  def show
    prepare_user_data
  end

  def update
    prepare_user_data
    if @user.update_attributes(user_params)
      flash[:notice] = I18n.t('user.account_update_successully')
      redirect_to after_update_profile_path
    else
      flash[:alert] = I18n.t('user.account_update_failed')
      render :show
    end
  end

  def change_password
    prepare_user_data
    if @account.update_with_password(change_password_params)
      flash[:notice] = I18n.t('user.password_changed_successfully')
      sign_in @account, :bypass => true
      redirect_to after_update_profile_path
    else
      @user = @account.rolable
      flash[:alert] = I18n.t('user.password_changed_failed')
      render :show
    end
  end

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
    @user = current_account
    if @user.update_attributes(params.require(:user).permit(:crop_x, :crop_y, :crop_h, :crop_w))
      flash[:notice] = I18n.t('user.update_avatar')
      redirect_to after_update_profile_path
    else
      flash[:alert] = @user.errors.messages #I18n.t('user.account_update_failed')
      redirect_to after_update_profile_path
    end
  end

  protected
  def prepare_user_data
    @account = current_account
    @user = @account.rolable
  end

  def user_params
    params.require(:user).permit(
        :first_name, :last_name, :civility, :birthday, :address, :city, :country, :zip_code, :mobile_phone,
        :telephone, :favorite_beting_website, :know_website_from, :secret_question, :answer_secret_question
    )
  end

  def change_password_params
    params.require(:account).permit(:current_password, :password, :password_confirmation)
  end
end