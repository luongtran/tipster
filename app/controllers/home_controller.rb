class HomeController < ApplicationController
  def index
  end

  def pricing
    @plans = Plan.all
  end

  def register
    @current_step = params[:step] || 'identification'
    if request.post?
      # check the request function is able to process
      # example: client request perform the 'payment' step -> check user is signed in, offer and at least on tipster in cart
    end
    prepare_registration_data
    render 'registrations/steps'
  end

  private

  def prepare_registration_data
    @data = {}
    @data[:tipsters_in_cart] = Tipster.where(id: tipster_ids_in_cart)
    @data[:selected_plan] = Plan.where(id: session[:plan_id]).first
  end

  def is_ready_to_payment?
    # check user is signed in, offer and at least on tipster in cart
    !(!current_user || tipster_ids_in_cart.empty?)
  end
end