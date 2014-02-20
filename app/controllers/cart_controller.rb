class CartController < ApplicationController

  def show
    if tipster_ids_in_cart.empty?
      flash[:alert] = "Your cart is empty"
      redirect_to top_tipster_url
    else
      @tipsters = Tipster.where(id: tipster_ids_in_cart)
    end

  end

  def add_tipster
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
    redirect_to top_tipster_url
  end

  def drop_tipster
    tipster_id = params[:id]
    session[:cart][:tipster_ids].delete(tipster_id) if session[:cart][:tipster_ids].include? tipster_id
    flash[:notice] = "Tipster droped"
    redirect_to registration_path(step: 'offer')
  end
end
