class Backoffice::ProfileController < ProfileController
  before_action :authenticate_account!, :tipster_required


  #def change_avatar
  #
  #end

  #def crop_avatar
  #end

  protected
  def user_params
    params.require(:user).permit(
        :display_name,
        :full_name
    )
  end

  def current_user
    current_tipster
  end

  def after_update_profile_path
    backoffice_my_profile_path
  end
end
