class Backoffice::SessionsController < Devise::SessionsController

  def new
    @account = Account.new
  end

  def create
    @account = Account.find_or_initialize_by(email: params[:account][:email])
    if @account.persisted? && @account.valid_password?(params[:account][:password]) && @account.rolable.is_a?(Tipster)
      sign_in @account
      flash.clear
      redirect_to after_sign_in_path_for(resource)
    else
      flash.now[:alert] = I18n.t('devise.failure.not_found_in_database')
      render :new
    end
  end

  protected
  def after_sign_in_path_for(resource)
    backoffice_dashboard_path
  end

  def after_sign_out_path_for(resource)
    backoffice_root_path
  end

  def require_no_authentication
    if current_tipster
      redirect_to backoffice_dashboard_url
    end
  end
end