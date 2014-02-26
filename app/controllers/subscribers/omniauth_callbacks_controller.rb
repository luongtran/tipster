class Subscribers::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authorize('Facebook')
  end

  def google_oauth2
    authorize('Google')
  end

  protected

  def authorize(provider = '')
    identity = Authorization.find_from_oauth(request.env["omniauth.auth"])
    subscriber = Subscriber.find_by(email: email_from_omniauth)
    subscriber = Subscriber.create_from_auth_info(request.env["omniauth.auth"]) unless subscriber
    # Add more authorization for subscriber
    subscriber.add_authorization(request.env["omniauth.auth"]) unless identity
    set_flash_message(:notice, :success, :kind => provider) if is_navigational_format?
    sign_in :user, subscriber
    redirect_to session[:return_url] || root_url
  end

  protected

  def email_from_omniauth
    request.env["omniauth.auth"]['info']['email']
  end
end