class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authorize
  end

  # Google login callback.
  def google_oauth2
    authorize
  end

  protected

  def authorize
    identity = Authorization.find_or_initialize_from_oauth(request.env["omniauth.auth"])
    unless subscriber = identity.subscriber
      subscriber = Subscriber.create_from_auth_info(request.env["omniauth.auth"], identity)
    end
    set_flash_message(:notice, :success, :kind => identity.provider) if is_navigational_format?
    sign_in_and_redirect subscriber, :event => :authentication #this will throw if user is not activated
  end
end