class Users::SessionsController < Devise::SessionsController

  def new
    super
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(Subscriber)
      initial_cart_session if session[:cart].nil?
    end
    super # Default by super class or your own path

  end

end