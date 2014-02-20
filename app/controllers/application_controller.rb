class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :fill_profile

  protected

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

  def add_tipster_to_cart(tipster_id)
    if Tipster.exists?(tipster_id)
      initial_cart_session if session[:cart].nil?
      (tipster_ids_in_cart.include? tipster_id) ? flash[:alert] = "Tipster already added to cart" : flash[:notice] = "Tipster added"
      session[:cart][:tipster_ids] << tipster_id unless tipster_ids_in_cart.include? tipster_id
    end
  end
end
