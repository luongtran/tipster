class Admin::SessionsController < Devise::SessionsController
  layout 'admin'

  def create
    super do
      unless resource.rolable.is_a? Admin
        sign_out resource
        flash.clear
        flash[:alert] = I18n.t('devise.failure.not_found_in_database')
      end
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