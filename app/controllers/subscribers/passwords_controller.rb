class Subscribers::PasswordsController < Devise::PasswordsController
  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    flash[:notice] = I18n.t("devise.passwords.send_instructions")
    root_path
  end
end