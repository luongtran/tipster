class SessionsController < Devise::SessionsController
   skip_before_action :fill_up_profile
  protected
  def after_sign_in_path_for(resource)
    raise 'Need to implement the method'
  end

  def after_sign_out_path_for(resource)
    raise 'Need to implement the method'
  end
end