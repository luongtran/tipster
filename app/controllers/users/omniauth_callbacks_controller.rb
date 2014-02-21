class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authorize('Facebook')
  end

  def google_oauth2
    authorize('Google')
  end

  def twitter
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = TWITTER_CONSUMER_KEY
      config.consumer_secret     = TWITTER_CONSUMER_SECRET
      config.access_token        = params[:oauth_token]
      config.access_token_secret = params[:oauth_verifier]
    end

    redirect_to root_url
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