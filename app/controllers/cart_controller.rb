class CartController < ApplicationController
  def show
    reset_cart_session
    if tipster_ids_in_cart.empty?
      flash[:alert] = I18n.t('cart.empty')
      redirect_to tipsters_url
    else
      @tipsters = Tipster.includes(:statistics).where(id: tipster_ids_in_cart).load_data
      if current_subscriber && current_subscriber.has_active_subscription?
        @subscription_active = true
      end
    end
  end

  def add_tipster
    unless selected_plan.nil?
      if selected_plan.price == 0
        empty_cart_session
        flash[:alert] = I18n.t('cart.free_plan_alert')
        redirect_to pricing_path and return
      end
      if session[:old_id]
        remove_tipster_from_cart(session[:old_id])
        session[:old_id] = nil
      end
      count_after_added = total_tipster + 1
      if count_after_added > (selected_plan.number_tipster + Subscription::MAX_ADDITIONAL_TIPSTERS)
        flash[:alert] = I18n.t('cart.limit_add_tipster', count: Subscription::MAX_ADDITIONAL_TIPSTERS)
        if tipster_ids_in_cart.size > 0
          redirect_to cart_url and return
        else
          redirect_to subscription_path and return
        end
      end

      tipster_id = params[:id]
      if Tipster.exists?(tipster_id)
        initial_cart_session if session[:cart].nil?
        if tipster_ids_in_cart.include? tipster_id
          flash[:alert] = I18n.t('cart.already_in_cart')
        else
          add_tipster_to_cart(tipster_id)
          session[:add_tipster_id] = tipster_id
          session[:failed_add_tipster_id] = nil
        end
      end
    else
      session[:tipster_first] = true
      session[:failed_add_tipster_id] = params[:id]
    end
    flash[:show_checkout_dialog] = true
    redirect_to tipsters_path and return
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
    after_drop_tipster_url =
        if tipster_ids_in_cart.empty?
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
