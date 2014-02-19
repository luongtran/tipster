class ProfilesController < ApplicationController
  before_action :authenticate_user!

  #This only example
  def new
    @profile = current_user.find_or_initial_profile
  end

  def create
    @profile = current_user.find_or_initial_profile
    params.permit!
    @profile.assign_attributes(params[:profile])
    if @profile.save
      redirect_to root_url
    else
      render :action => :new
    end
  end

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
  end

  private

  def profile_params
    params.require(:profile).permit!
  end

end