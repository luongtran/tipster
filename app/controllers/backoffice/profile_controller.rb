class Backoffice::AccountsController < AccountsController
  before_action :authenticate_tipster!

  # Inherited all super actions

  protected

  def current_user
    current_tipster
  end

  def after_update_profile_path
    backoffice_my_profile_path
  end
end
