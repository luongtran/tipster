class CartController < ApplicationController

  def show
    reset_cart_session
    if tipster_ids_in_cart.empty?
      flash[:alert] = "Your cart is empty"
      redirect_to top_tipsters_url
    else
      @tipsters = Tipster.where(id: tipster_ids_in_cart)
      if current_user && current_user.subscription && current_user.subscription.active?
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
        flash[:notice] = "Tipster added"
      end
    else
      flash[:alert] = "Request is invalid"
    end
    redirect_to top_tipsters_url
  end

  def drop_tipster
    tipster_id = params[:id]
    session[:cart][:tipster_ids].delete(tipster_id) if session[:cart][:tipster_ids].include? tipster_id
    if current_user && current_user.subscription
      tipster = Tipster.find tipster_id
      current_user.subscription.inactive_tipsters.delete(tipster) if current_user.subscription.inactive_tipsters.include? tipster
    end
    flash[:notice] = "Tipster droped"
    redirect_to params[:return_url].present? ? params[:return_url] : cart_path
  end

  private
  def already_purchase
    if current_user && current_user.subscription && current_user.subscription.active
        current_user.subscription.active_tipsters.each {|tipster| session[:cart][:tipster_ids].delete(tipster.id.to_s)}
    end
  end
end
