class CartController < ApplicationController
  before_action :subscriber_required

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
    if selected_plan.nil?
      flash[:alert] = I18n.t("errors.messages.unselect_plan")
      unless params["step"]
        redirect_to pricing_path and return
      else
        redirect_to subscribe_choose_offer_path and return
      end
    end

    count_after_added = tipster_ids_in_cart.size + 1
    if count_after_added > (selected_plan.number_tipster + Subscription::MAX_ADDTIONAL_TIPSTERS)
      flash[:alert] = I18n.t('cart.limit_add_tipster', count: Subscription::MAX_ADDTIONAL_TIPSTERS)
      redirect_to cart_url and return
    end

    unless selected_plan.nil?
      select_plan = Plan.find_by_id(session[:plan_id])
      if select_plan.price == 0
        unless params["step"]
          redirect_to pricing_path, alert: I18n.t('cart.free_plan_alert') and return
        end
      end
    end

    tipster_id = params[:id]
    if Tipster.exists?(tipster_id)
      initial_cart_session if session[:cart].nil?
      if tipster_ids_in_cart.include? tipster_id
        flash[:alert] = I18n.t('cart.already_in_cart')
      else
        add_tipster_to_cart(tipster_id)
      end
    end
    flash[:show_checkout_dialog] = true
    unless params['step']
      redirect_to tipsters_url
    else
      redirect_to subscribe_choose_offer_path(sport: 'all', enable: 'tipster') and return
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
    empty_cart_session
    flash[:notice] = I18n.t('cart.empty')
    redirect_to params[:return_url].present? ? params[:return_url] : root_path
  end

end
