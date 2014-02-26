class ProfilesController < ApplicationController
  before_action :authenticate_subscriber!
  skip_before_action :fill_profile, only: [:my_profile]

  def my_profile
    @user = User.includes(:coupon_codes).where(id: current_user.id).first
    @profile = @user.find_or_initial_profile
    if request.post?
      if @profile.update_attributes(profile_params)
        if session[:plan_id].nil?
          flash[:notice] = 'Please select a plan bellow to continue'
          redirect_to pricing_path
        else
          redirect_to subscribe_payment_method_path
        end
      else
        flash.now[:alert] = 'Profile updated failed'
      end
    end
  end

  private

  def profile_params
    params.require(:profile).permit!
  end

end