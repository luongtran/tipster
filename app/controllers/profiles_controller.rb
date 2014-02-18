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

end