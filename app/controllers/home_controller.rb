class HomeController < ApplicationController
  def index
  end

  def pricing
    @plans = Plan.all
  end

  def register
    @current_step = params[:step] || 'identification'
    prepare_registration_data
    render 'registrations/steps'
  end

  private

  def prepare_registration_data
    @data = {}
    @data[:tipsters_in_cart] = Tipster.where(id: tipster_ids_in_cart)
    @data[:selected_plan] = Plan.where(id: session[:plan_id]).first
  end
end