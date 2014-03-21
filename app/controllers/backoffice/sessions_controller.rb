class Backoffice::SessionsController < SessionsController

  def create
    super do
      unless resource.rolable.is_a? Tipster
        sign_out resource
        flash.clear
        flash[:alert] = I18n.t('devise.failure.not_found_in_database')
      end
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
      redirect_to backoffice_dashboard_url, alert: I18n.t('devise.failure.already_authenticated')
    end
  end
end