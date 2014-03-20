class CartController < ApplicationController
  def show
    reset_cart_session
    if tipster_ids_in_cart.empty?
      flash[:alert] = I18n.t('cart.empty')
      redirect_to tipsters_url
    else
      @tipsters = Tipster.where(id: tipster_ids_in_cart)
      @tipsters.each { |tipster| tipster.get_statistics }
      if current_subscriber && current_subscriber.has_active_subscription?
        @subscription_active = true
      end
    end
  end

  def add_tipster
    unless selected_plan.nil?
      if session[:old_id]
        remove_tipster_from_cart(session[:old_id])
        session[:old_id] = nil
      end
      count_after_added = tipster_ids_in_cart.size + 1
      if count_after_added > (selected_plan.number_tipster + Subscription::MAX_ADDITIONAL_TIPSTERS)
        flash[:alert] = I18n.t('cart.limit_add_tipster', count: Subscription::MAX_ADDITIONAL_TIPSTERS)
        redirect_to cart_url and return
      end
      if selected_plan.price == 0
        unless params["step"]
          session[:failed_add_tipster_id] = params[:id]
          redirect_to subscribe_choose_offer_path, alert: I18n.t('cart.free_plan_alert') and return
        end
      end
      tipster_id = params[:id]
      if Tipster.exists?(tipster_id)
        initial_cart_session if session[:cart].nil?
        if tipster_ids_in_cart.include? tipster_id
          flash[:alert] = I18n.t('cart.already_in_cart')
        else
          add_tipster_to_cart(tipster_id)
          session[:add_tipster_id] = params[:id]
          flash[:show_checkout_dialog] = true
        end
      end
    else
      session[:tipster_first] = true
      flash[:show_checkout_dialog] = true
      session[:failed_add_tipster_id] =  session[:old_id] = params[:id]
    end
    unless params['step']
      redirect_to tipsters_url
    else
      redirect_to subscribe_choose_tipster_path and return
    end
  end

  def drop_tipster
    tipster_id = params[:id]
    remove_tipster_from_cart(tipster_id) if tipster_ids_in_cart.include?(tipster_id)
    if current_subscriber && current_subscriber.subscription
      tipster = Tipster.find tipster_id
      current_subscriber.subscription.inactive_tipsters.delete(tipster) if current_subscriber.subscription.inactive_tipsters.include? tipster
    end
    flash[:notice] = "Tipster droped.#{'Your cart is empty.' if tipster_ids_in_cart.empty?}"
    return_url = params[:return_url].presence
    after_drop_tipster_url = if tipster_ids_in_cart.empty?
                               tipsters_url
                             else
                               cart_url
                             end
    redirect_to return_url || after_drop_tipster_url
  end

  def empty
    empty_subscribe_session
    flash[:notice] = I18n.t('cart.empty')
    redirect_to params[:return_url].present? ? params[:return_url] : cart_path
  end

end
