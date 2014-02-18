class PaymentController < ApplicationController

  # POST /payment
  # Initialize invoice and redirect to Paypal payment page
  def create
    user = current_user
    invoice = Invoice.new

    # TODO, calculate the amount, coupon
    amount = 13
    redirect_uri = invoice.setup_purchase(
        amount,
        user,
        return_url: success_payment_url,
        cancel_return_url: cancel_payment_url,
        description: 'Tipster Hero payment'
    )
    redirect_to redirect_uri
  end

  # GET /payment/success
  def success
    # Throw exception if the token param is non-exist
    invoice = Invoice.find_by_token! params[:token]
    invoice.purchase(:token => params[:token], :payer_id => params[:PayerID], :ip => request.remote_ip)
    redirect_to root_url, notice: 'Thank you for payment'
  end

  # GET /payment/cancel
  def cancel
    invoice = Invoice.find_by_token! params[:token]
    invoice.cancel
    redirect_to root_url, notice: 'Payment request canceled'
  end

end