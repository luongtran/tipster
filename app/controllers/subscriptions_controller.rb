class SubscriptionsController < ApplicationController
  def plan_select
    session[:plan_id] = params[:id]
    redirect_to top_tipster_url
  end
  #Step 1
  def show
    if session[:cart] && session[:cart][:tipster_ids].present?
      @tipsters = Tipster.where(id: session[:cart][:tipster_ids])
    else
      flash[:alert] = "Your cart is empty"
      redirect_to top_tipster_url
    end
  end
  #Step 2
  def identification
    if user_signed_in?
      redirect_to subscriptions_payment_url
    else
      flash[:alert] = "Please login or register to continue!"
    end
  end
  #Step 3
  def payment
    @plan = Plan.find session[:plan_id]
    @tipsters = Tipster.where(id: session[:cart][:tipster_ids])
  end
end