class Subscribers::RegistrationsController < Devise::RegistrationsController
  #before_action :configure_permitted_parameters, :only => [:create, :update]

  def new
    if request.xhr?
      @subscriber = Subscriber.new
      @subscriber.build_account
    else
      render_404
    end
  end

  def create
    build_resource(account_params)
    resource.rolable = Subscriber.new(create_with_only_account: true)
    # Generate confirm token but not send email
    resource.skip_confirmation_notification!
    if resource.save
      sign_up(resource_name, resource)
      render json: {
          success: true,
          path: after_sign_up_path_for(resource)
      }
    else
      clean_up_passwords resource
      render json: {
          success: false,
          errors: resource.errors
      }
    end
  end

  # New subscriber
  #def create
  #  @subscriber = Subscriber.register(subscriber_params)
  #  resource
  #  if @subscriber.save
  #    resource = @subscriber.account
  #    if resource.active_for_authentication?
  #      set_flash_message :notice, :signed_up if is_flashing_format?
  #      sign_up(resource_name, resource)
  #      respond_with resource, location: after_sign_up_path_for(resource)
  #    else
  #      set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
  #      expire_data_after_sign_in!
  #      respond_with resource, location: after_inactive_sign_up_path_for(resource)
  #    end
  #  else
  #    clean_up_passwords resource
  #    #respond_with resource
  #    render :new
  #  end
  #end

  protected
  def after_sign_up_path_for(resource)
    pricing_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation, subscriber: [:first_name, :last_name])
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name,
               :password, :password_confirmation, :current_password)
    end
  end

  def subscriber_params
    params.require(:subscriber).permit(:first_name, :last_name, account_attributes: [:email, :password, :password_confirmation])
  end

end