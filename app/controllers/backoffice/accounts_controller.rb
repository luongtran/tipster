class Backoffice::AccountsController < AccountsController
  before_action :authenticate_tipster!

  protected

  def current_user
    current_tipster
  end

  def after_update_account_path
    backoffice_my_account_path
  end
end
