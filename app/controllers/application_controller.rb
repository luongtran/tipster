class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :fill_profile

  protected

  # Render bad request(invalid params, etc ...)
  def render_400
    render nothing: true, status: 400
  end

  def fill_profile
    if current_user && !current_user.profile
      redirect_to my_profile_url, notice: 'Please update your profile'
    end
  end

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
    session[:cart][:tipster_ids].uniq
  end

  def empty_subscribe_session
    empty_cart_session
    session[:plan_id] = nil
    # Maybe clear more session vars: coupon code, payment info ...
  end
end
