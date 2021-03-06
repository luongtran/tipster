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
    account = Account.find_by(email: email_from_omniauth)

    if account
      subscriber = account.rolable
    else
      # Create account vs subscriber if doesn't exist
      subscriber = Subscriber.create_from_auth_info(request.env["omniauth.auth"])
      account = subscriber.account
    end

    # Add more authorization for subscriber
    subscriber.add_authorization(request.env["omniauth.auth"]) unless identity

    set_flash_message(:notice, :success, kind: provider) if is_navigational_format?

    sign_in account
    redirect_to session[:return_url] || pricing_url
  end

  def after_omniauth_failure_path_for(resource_name)
    root_path
  end

  def email_from_omniauth
    request.env["omniauth.auth"]['info']['email']
  end
end