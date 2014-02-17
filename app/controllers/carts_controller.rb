class CartsController < ApplicationController
  before_filter :load_cart
  def add_tipster
    @cart.tipsters << params[:id]
    render nothing: true
  end
  private
  def load_cart
    @cart = Cart.find session[:cart_id]
  end
end
