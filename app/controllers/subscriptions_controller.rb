class SubscriptionsController < ApplicationController
  before_filter :authenticate_account!, only: [:show, :remove_inactive_tipster]

  def select_plan
    selected_plan = Plan.find(params[:id])
    session[:plan_id] = selected_plan.id
    if selected_plan.free?
      redirect_to subscribe_choose_offer_url
    else
      redirect_to tipsters_url
    end
  end

  def select_free_plan
    if Plan.exists?(session[:plan_id])
      session[:free_plan] = true
      if current_subscriber
        if current_subscriber.subscription.active?

        else
          current_subscriber.build_subscription(plan_id: session[:plan_id])
        end
      else
        redirect_to subscribe_identification_path
      end
    end
  end

  def show
    @subscription = current_subscriber.subscription
  end

  def remove_inactive_tipster
    @subscription = current_subscriber.subscription
    if @subscription.can_change_tipster?
      @subscription.remove_tipster(params[:id])
      redirect_to action: 'show', :notice => "Tipster unfollow"
    else
      redirect_to action: 'show', notice: "You can change your follow tipster on day #{current_subscription.active_at.strftime('%d')}  of the month"
    end
  end
end