class ProfilesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :fill_profile, only: [:my_profile, :update]

  def update
    @profile = current_user.find_or_initial_profile
    @profile.update_attributes(profile_params)
  end

  def show
    @profile = current_user.find_or_initial_profile
    #redirect_to update profile if profile is not completed
  end

  def my_profile
    @profile = current_user.find_or_initial_profile
    if request.post?
      if @profile.update_attributes(profile_params)
        flash[:notice] = 'Profile updated successfully'
      else
        flash[:alert] = 'Profile updated failed'
      end
    end
  end

  private

  def profile_params
    params.require(:profile).permit!
  end

end