class ProfileController < ApplicationController
  before_action :authenticate_account!
  skip_before_action :fill_up_profile

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

  protected
  def user_params
    raise 'Need to implement the method'
  end

  def prepare_user_data
    @account = current_account
    @user = @account.rolable
  end

  def change_password_params
    params.require(:account).permit(:current_password, :password, :password_confirmation)
  end
end