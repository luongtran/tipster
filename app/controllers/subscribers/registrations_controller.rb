class Subscribers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, :only => [:create, :update]

  def new
    super
  end

  # New subscriber
  def create
    build_resource(sign_up_params)
    if resource.save
      resource.build_profile(profile_params) if params[:subscriber][:profile]
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name,
               :email, :password, :password_confirmation, profile_attributes: [:civility, :birthday, :address, :city, :country, :zip_code, :mobile_phone, :telephone, :favorite_betting_website, :know_website_from, :secret_question, :answer_secret_question])
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name,
               :password, :password_confirmation, :current_password)
    end
  end

  def profile_params
    params.require(:subscriber).require(:profile).permit(:civility, :birthday, :address, :city, :country, :zip_code, :mobile_phone, :telephone, :favorite_betting_website, :know_website_from, :secret_question, :answer_secret_question)
  end
end