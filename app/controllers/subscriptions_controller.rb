class SubscriptionsController < ApplicationController
#  before_filter :authenticate_user! , except: [:plan_select,:show]
  skip_before_filter :verify_authenticity_token, :only => [:ipn_notify]

  def plan_select
    session[:plan_id] = params[:id]
    redirect_to top_tipster_url
  end

  #Step 1
  def show
    if session[:cart] && session[:cart][:tipster_ids].present?
      @tipsters = Tipster.where(id: session[:cart][:tipster_ids])
    else
      flash[:alert] = "Your cart is empty"
      redirect_to top_tipster_url
    end
  end

  #Step 2
  def identification
    if user_signed_in?
      if session[:plan_id]
        flash[:notice] = 'Select an payment method bellow !'
        redirect_to subscriptions_payment_url
      else
        flash[:error] = 'Please choose an plan bellow !'
        redirect_to pricing_url and return
      end
    else
      flash[:error] = "Please login or register to continue!"
    end
  end

  #Step 3
  def payment
    @plan = Plan.find session[:plan_id]
    @tipsters = Tipster.where(id: session[:cart][:tipster_ids])
  end

  #Payment

  def payment_init
    plan = Plan.find(session[:plan_id])
    tipster_count = session[:cart][:tipster_ids].count
    @last_price = plan.price + tipster_count * 9.9
    @api = PayPal::SDK::Merchant.new
    @do_direct_payment = @api.build_do_direct_payment({
                                                          :DoDirectPaymentRequestDetails => {
                                                              :PaymentAction => "Sale",
                                                              :PaymentDetails => {
                                                                  :OrderTotal => {
                                                                      :currencyID => "EUR",
                                                                      :value => "#{@last_price}"},
                                                                  :NotifyURL => "http://1.53.233.90:3000/subscriptions/ipn_notify"},
                                                              :CreditCard => {
                                                                  :CreditCardType => "Visa",
                                                                  :CreditCardNumber => "4904202183894535",
                                                                  :ExpMonth => 12,
                                                                  :ExpYear => 2022,
                                                                  :CVV2 => "962"}}})


    # Make API call & get response
    @response = @api.do_direct_payment(@do_direct_payment)

# Access Response
    if @response.success?
      @response.TransactionID
    else
      @response.Errors
    end

  end

  def ipn_notify
    # Doing something here
    render nothing: true
  end
end