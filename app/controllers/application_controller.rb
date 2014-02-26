class ApplicationController < ActionController::Base
  layout :find_layout
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :fill_profile

  helper_method :tipster_ids_in_cart, :current_user

  protected

  # Render bad request(invalid params, etc ...)
  def render_400
    render nothing: true, status: 400
  end

  def fill_profile
    if current_subscriber && !current_subscriber.profile
      redirect_to my_profile_url, notice: 'Please update your profile'
    end
  end

  # Clear and create new cart
  def initial_cart_session
    session[:cart] = {}
    session[:cart][:tipster_ids] = []
  end

  def reset_cart_session
    if current_user && current_user.subscription
      current_user.subscription.inactive_tipsters.each do |tipster|
        session[:cart][:tipster_ids] << tipster.id.to_s unless session[:cart][:tipster_ids].include? tipster.id.to_s
      end
      current_user.subscription.active_tipsters.each do |tipster|
        session[:cart][:tipster_ids].delete(tipster.id.to_s) if session[:cart][:tipster_ids].include? tipster.id.to_s
      end
    end
  end

  def empty_cart_session
    session[:cart] = nil
  end

  # Return an array of tipster's id in cart from session
  def tipster_ids_in_cart
    initial_cart_session if session[:cart].nil?
    session[:cart][:tipster_ids].uniq
  end

  def current_user
    current_subscriber || current_tipster #|| current_admin
  end

  # Return an array of tipster's id in current user subscription
  def tipster_ids_in_subscription
    if current_user && current_user.subscription && current_user.subscription.active?
      current_user.subscription.tipster_ids
    end
  end

  def empty_subscribe_session
    empty_cart_session
    session[:plan_id] = nil
    session[:using_coupon] = nil
    # Maybe clear more session vars: coupon code, payment info ...
  end

  private
  def find_layout
    'backoffice' if self.class.name.split("::").first == 'Backoffice'
  end
end
