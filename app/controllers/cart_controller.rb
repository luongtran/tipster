class CartController < ApplicationController
  before_action :subscriber_required

  def show
    reset_cart_session
    if tipster_ids_in_cart.empty?
      flash[:alert] = "Your cart is empty"
      redirect_to tipsters_url
    else
      @tipsters = Tipster.where(id: tipster_ids_in_cart)
      if current_subscriber && current_subscriber.has_active_subscription?
        @subscription_active = true
      end
    end
  end

  def add_tipster
    unless session[:plan_id].nil?
      select_plan = Plan.find_by_id(session[:plan_id])
      if select_plan.price == 0
        redirect_to pricing_path, alert: "You cannot follow any tipsters with Free plan, please select another!" and return
      end
    end
    tipster_id = params[:id]
    if Tipster.exists?(tipster_id)
      initial_cart_session if session[:cart].nil?
      if tipster_ids_in_cart.include? tipster_id
        flash[:alert] = "Tipster already added to cart"
      else
        session[:cart][:tipster_ids] << tipster_id
      end
    else
      flash[:alert] = "Request is invalid"
    end
    flash[:show_checkout_dialog] = true
    redirect_to tipsters_url
  end

  def drop_tipster
    tipster_id = params[:id]
    session[:cart][:tipster_ids].delete(tipster_id) if session[:cart][:tipster_ids].include? tipster_id
    if current_subscriber && current_subscriber.subscription
      tipster = Tipster.find tipster_id
      current_subscriber.subscription.inactive_tipsters.delete(tipster) if current_subscriber.subscription.inactive_tipsters.include? tipster
    end
    flash[:notice] = "Tipster droped"
    redirect_to params[:return_url].present? ? params[:return_url] : cart_path
  end

  def empty
    empty_cart_session
    flash[:notice] = "Your cart is empty"
    redirect_to params[:return_url].present? ? params[:return_url] : root_path
  end

  private
  def already_purchase
    if current_subscriber && current_subscriber.subscription && current_subscriber.subscription.active
      current_subscriber.subscription.active_tipsters.each { |tipster| session[:cart][:tipster_ids].delete(tipster.id.to_s) }
    end
  end
end
