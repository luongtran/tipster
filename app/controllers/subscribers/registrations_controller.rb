class Subscribers::RegistrationsController < Devise::RegistrationsController
  #before_action :configure_permitted_parameters, :only => [:create, :update]

  def new
    build_resource({})
    resource.rolable = Subscriber.new
    respond_with self.resource
  end

  # New subscriber
  def create
    build_resource(sign_up_params)
    resource.rolable = Subscriber.new(subscriber_params)

    valid = resource.valid?
    valid = resource.rolable.valid? && valid

    if valid && resource.save
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
      u.permit(:email, :password, :password_confirmation, :subscriber => [:first_name, :last_name])
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name,
               :password, :password_confirmation, :current_password)
    end
  end

  #
  #def account_params
  #  params.require(:account).permit(:email, :password, :password_confirmation, :subscriber => [:first_name, :last_name])
  #end

  def subscriber_params
    params.require(:account).require(:subscriber).permit(:first_name, :last_name)
  end
end