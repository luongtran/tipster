class Subscribers::AccountsController < AccountsController
  before_action :authenticate_subscriber!

  protected
  def current_user
    current_subscriber
  end

  def after_update_account_path
    my_account_path
  end
end