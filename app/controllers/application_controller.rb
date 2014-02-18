class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    subscriptions_identification_path
  end
  protected
  #
  #def fill_profile
  #  if current_user && !current_user.profile
  #    redirect_to new_profile_url
  #  end
  #end

  # Clear and create new cart
  def initial_cart_session
    session[:cart] = {}
    session[:cart][:tipster_ids] = []
  end

  def empty_cart_session
    session[:cart] = nil
  end

  # Return an array of tipster's id in cart from session
  def tipster_ids_in_cart
    initial_cart_session if session[:cart].nil?
    session[:cart][:tipster_ids]
  end
end
