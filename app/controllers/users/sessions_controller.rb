class Users::SessionsController < Devise::SessionsController
  skip_before_action :fill_profile
  def new
    super
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(Subscriber)
      initial_cart_session if session[:cart].nil?
    end
    flash.clear
    params[:return_path] || super
  end

end