class CartsController < ApplicationController

  def add_tipster
    tipster_id = params[:id]
    if Tipster.exists?(tipster_id)
      initial_cart_session if session[:cart].nil?
      session[:cart][:tipster_ids] << tipster_id unless session[:cart][:tipster_ids].include? tipster_id
    end
    redirect_to pricing_url
  end

  def drop_tipster
    tipster_id = params[:id]
    session[:cart][:tipster_ids].delete(tipster_id) if session[:cart][:tipster_ids].include? tipster_id

    # Continue to coding here
  end

end
