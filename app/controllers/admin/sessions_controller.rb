class Admin::SessionsController < Devise::SessionsController
  layout 'admin'

  def create
    @account = Account.find_or_initialize_by(email: params[:account][:email])
    if @account.persisted? && @account.valid_password?(params[:account][:password]) && @account.rolable.is_a?(Admin)
      sign_in @account
      flash.clear
      redirect_to after_sign_in_path_for(resource)
    else
      flash[:alert] = I18n.t('devise.failure.not_found_in_database')
      flash[:email] = params[:account][:email]
      redirect_to admin_root_url
    end
  end

  protected
  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  def after_sign_out_path_for(resource)
    admin_root_path
  end
end