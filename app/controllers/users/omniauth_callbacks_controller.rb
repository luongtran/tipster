class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    identity = Authorization.find_or_initialize_from_oauth(request.env["omniauth.auth"])
    unless subscriber = identity.subscriber
      subscriber = Subscriber.create_from_auth_info(request.env["omniauth.auth"], identity)
    end
    set_flash_message(:notice, :success, :kind => 'facebook') if is_navigational_format?
    sign_in_and_redirect subscriber, :event => :authentication #this will throw if user is not activated
  end

  # Google login callback.
  def google_oauth2
    subdomain = params[:state]
    @user = User.find_for_oauth(request.env["omniauth.auth"], subdomain, current_user)
    if @user.persisted_and_confirmed?
      redirect_to new_user_session_url(:token => @user.login_token, :subdomain => subdomain)
    else
      session["devise.social_network_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url(:omni => request.env["omniauth.auth"], :subdomain => subdomain)
    end

  end

end