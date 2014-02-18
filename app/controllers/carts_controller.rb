class CartsController < ApplicationController

  def add_tipster
    tipster_id = params[:id]
    if Tipster.exists?(tipster_id)
      initial_cart_session if session[:cart].nil?
      (session[:cart][:tipster_ids].include? tipster_id)?  flash[:alert] = "Tipster already in cart": flash[:notice] = "Tipster added"
      session[:cart][:tipster_ids] << tipster_id unless session[:cart][:tipster_ids].include? tipster_id
    end
    redirect_to top_tipster_url
  end

  def drop_tipster
    tipster_id = params[:id]
    session[:cart][:tipster_ids].delete(tipster_id) if session[:cart][:tipster_ids].include? tipster_id
    flash[:notice] = "Tipster droped"
    redirect_to cart_show_url
  end

  def show
    if session[:cart] && session[:cart][:tipster_ids].present?
      @tipsters = Tipster.where(id: session[:cart][:tipster_ids])
    else
      flash[:alert] = "Your cart is empty"
      redirect_to top_tipster_url
    end
  end
end
