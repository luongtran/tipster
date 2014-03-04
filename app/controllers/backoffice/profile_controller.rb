class Backoffice::AccountsController < AccountsController
  before_action :authenticate_tipster!

  def change_avatar

  end

  def crop_avatar

  end

  protected

  def current_user
    current_tipster
  end

  def after_update_profile_path
    backoffice_my_profile_path
  end
end
