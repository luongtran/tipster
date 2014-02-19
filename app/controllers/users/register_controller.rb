class Users::RegisterController < ApplicationController

  def show
    render_step(params[:step] || 'identification')
  end

  def identification
    action = params[:act]
    case action
      when 'update_profile'
        @profile = current_user.create_profile(profile_params)
      when 'facebook'
        session[:return_url] = register_url(step: 'identification')
        redirect_to user_omniauth_authorize_path(:facebook) and return
      when 'google'
        session[:return_url] = register_url(step: 'identification')
        redirect_to user_omniauth_authorize_path(:google_oauth2) and return
    end
    render_step('identification')
  end

  def payment
    if is_ready_to_payment?
      render_step('payment')
    else
      redirect_to register_url(step: 'identification')
    end
  end

  private

  def perform_login

  end

  def render_step(current_step)
    prepare_registration_data
    @current_step = current_step
    render 'users/register/steps'
  end

  def prepare_registration_data
    @data = {
        tipsters_in_cart: Tipster.where(id: tipster_ids_in_cart),
        selected_plan: Plan.where(id: session[:plan_id]).first
    }
    @data[:current_profile] = (@profile || current_user.find_or_initial_profile) if current_user
  end

  def is_ready_to_payment?
    # check user is signed in, offer and at least on tipster in cart
    !(!current_user || tipster_ids_in_cart.empty? || !session[:plan_id])
  end

  def profile_params
    params[:profile].permit!
  end
end