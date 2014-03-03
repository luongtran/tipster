class AccountsController < ApplicationController

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_account(user_params)
      flash[:notice] = I18n.t('user.account_update_successully')
      redirect_to after_update_account_path
    else
      flash[:alert] = I18n.t('user.account_update_failed')
      render :show
    end
  end

  def change_password
    @user = current_user
    if @user.update_with_password(change_password_params)
      flash[:notice] = I18n.t('user.password_changed_successfully')
      sign_in @user, :bypass => true
      redirect_to after_update_account_path
    else
      flash[:alert] = I18n.t('user.password_changed_failed')
      render :show
    end
  end

  def change_avatar
    @user = current_user
    if @user.update_attribute(:avatar, params.require(:user).permit(:avatar,:avatar_cache)[:avatar])
      flash[:notice] = I18n.t('user.avatar_update_successully')
      redirect_to after_update_account_path
    else
      flash[:alert] = I18n.t('user.account_update_failed')
      render :show
    end
  end

  def crop_avatar
    @user = current_user
    if @user.update_attributes(params.require(:user).permit(:crop_x,:crop_y,:crop_h,:crop_w))
      flash[:notice] = I18n.t('user.update_avatar')
      redirect_to after_update_account_path
    else
      flash[:alert] = @user.errors.messages #I18n.t('user.account_update_failed')
      redirect_to after_update_account_path
    end
  end

  protected

  def current_user
    # Need to override in the subclass
    raise 'This method should be overriden and return the current subscriber or tipster'
  end

  def after_update_account_path
    # Need to override in the subclass
    raise 'This method should be overriden and return the path after update account'
  end

  def user_params
    params.require(:user).permit(
        :first_name,
        :last_name,
        :avatar,
        :avatar_cache,
        profile_attributes: [
            :civility, :birthday, :address, :city, :country, :zip_code, :mobile_phone, :telephone,
            :favorite_betting_website, :know_website_from, :secret_question, :answer_secret_question
        ]
    )
  end

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end