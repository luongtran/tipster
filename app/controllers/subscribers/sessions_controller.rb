class Subscribers::SessionsController < SessionsController
  protected
  
  def after_sign_in_path_for(resource)
    if resource.rolable.is_a?(Subscriber)
      if session[:cart].nil?
        initial_cart_session
      else
        reset_cart_session
      end
    end
    flash.clear
    params[:return_path] || root_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

end