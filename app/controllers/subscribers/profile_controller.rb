class Subscribers::ProfileController < ProfileController
  before_action :subscriber_required

  protected
  def user_params
    params.require(:user).permit(
        :first_name, :last_name, :civility, :birthday, :address, :city, :country, :zip_code, :mobile_phone,
        :telephone, :favorite_beting_website, :know_website_from, :secret_question, :answer_secret_question
    )
  end

  def after_update_profile_path
    my_profile_path
  end
end