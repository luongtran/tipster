class Subscribers::AccountsController < AccountsController
  # Inherited all super actions

  protected
  def after_update_account_path
    my_account_path
  end
end