class Subscribers::ProfileController < ProfileController
  before_action :subscriber_required

  protected
  def user_params
    params.require(:user).permit(
        :first_name, :last_name, :nickname, :gender, :receive_tip_methods, :birthday, :address, :city, :country, :zip_code, :mobile_phone,
        :telephone, :favorite_beting_website, :know_website_from, :secret_question, :answer_secret_question, :receive_info_from_partners
    )
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