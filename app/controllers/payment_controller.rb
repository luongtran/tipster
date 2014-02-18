class PaymentController < ApplicationController

  # POST /payment
  # Initialize invoice and redirect to Paypal payment page
  def create
    user = current_user
    invoice = Invoice.new
    # TODO, calculate the amount
    amount = 7
    redirect_uri = invoice.setup!(user, success_payment_url, cancel_payment_url, amount)
    redirect_to redirect_uri
  end

  # GET /payment/success
  # Params: token
  def success
    # Throw exception if the token param is non-exist
    invoice = Invoice.find_by_token! params[:token]
    # Checkout and saving the payment info
    invoice.complete!(params[:PayerID])
    redirect_to root_url, notice: 'Payment transaction completed'
  end

  def cancel
    invoice = Invoice.find_by_token! params[:token]
    invoice.cancel
    redirect_to root_url, notice: 'Payment request canceled'
  end
end