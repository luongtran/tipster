class Subscribers::SessionsController < SessionsController

  def create
    #self.resource = warden.authenticate!(auth_options)
    #set_flash_message(:notice, :signed_in) if is_flashing_format?
    #sign_in(resource_name, resource)
    #yield resource if block_given?
    #respond_with resource, :location => after_sign_in_path_for(resource)
    @account = Account.find_by(email: params[:account][:email])
    if @account && @account.valid_password?(params[:account][:password])
      sign_in @account
      render json: {
          success: true,
          path: after_sign_in_path_for(resource)
      }
    else
      render json: {
          success: false,
          error: I18n.t("account.invalid")
      }
    end
  end
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