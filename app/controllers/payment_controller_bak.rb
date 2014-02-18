#class PaymentController < ApplicationController
#  rescue_from Paypal::Exception::APIError, with: :paypal_api_error
#
#  # POST /payment
#  # Initialize invoice and redirect to Paypal payment page
#  def create
#    user = current_user
#    invoice = Invoice.new
#    # TODO, calculate the amount
#    amount = 7
#    redirect_uri = invoice.setup!(user, success_payment_url, cancel_payment_url, amount)
#    redirect_to redirect_uri
#  end
#
#  # GET /payment/success
#  # Params: token
#  def success
#    # Throw exception if the token param is non-exist
#    invoice = Invoice.find_by_token! params[:token]
#    # Checkout and saving the payment info
#    invoice.complete!(params[:PayerID])
#    redirect_to root_url, notice: 'Payment transaction completed'
#  end
#
#  # GET /payment/cancel
#  # Params: token
#  def cancel
#    invoice = Invoice.find_by_token! params[:token]
#    invoice.cancel
#    redirect_to root_url, notice: 'Payment request canceled'
#  end
#
#  private
#
#  def paypal_api_error(e)
#    flash[:alert] = e.response.details.collect(&:long_message).join('<br />')
#    redirect_to root_url
#  end
#
#end