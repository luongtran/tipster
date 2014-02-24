class UsersController < ApplicationController
  before_filter :authenticate_user!

  def my_account
    @user ||= current_user
    if request.post?
      if @user.update_attributes(user_params)
        flash[:notice] = I18n.t('user.account_update_successully')
        redirect_to my_account_url
      else
        flash[:alert] = I18n.t('user.account_update_failed')
      end
    end
  end

  def change_password
    @user = current_user
    if @user.update_with_password(change_password_params)
      flash[:notice] = I18n.t('user.password_changed_successfully')
      sign_in @user, :bypass => true
      redirect_to my_account_url
    else
      flash[:alert] = I18n.t('user.password_changed_failed')
    end
    render :my_account
  end

  private

  def user_params
    params.require(:user).permit(
        :first_name,
        :last_name,
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