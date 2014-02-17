class Users::SessionsController < Devise::SessionsController
  def new
    super
  end

  protected

  def after_sign_in_path_for(resource)
    cart = Cart.create!
    session[:cart_id] = cart.id
  end

end