class Backoffice::SessionsController < SessionsController
  before_action :tipster_required
  protected
  def after_sign_in_path_for(resource)
    backoffice_root_path
  end

  def after_sign_out_path_for(resource)
    backoffice_root_path
  end

end