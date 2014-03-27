class Subscribers::SessionsController < Devise::SessionsController
  def new
    #Worker.update_tipster_statistics
    super
  end
  def create
    if request.xhr?
      @account = Account.find_by(email: params[:account][:email])
      if @account && @account.is_a?(Subscriber) && @account.valid_password?(params[:account][:password])
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
    else
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, :location => after_sign_in_path_for(resource)
      super
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

  def require_no_authentication
    if current_subscriber
      redirect_to root_url, alert: I18n.t('devise.failure.already_authenticated')
    end
  end
end