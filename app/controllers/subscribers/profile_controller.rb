class Subscribers::ProfileController < ProfileController
  # Inherited all super actions

  protected
  def after_update_profile_path
    my_profile_path
  end
end