class Payment

  class << self
    def setup_purchase(amount, user, options = {})
      response = gateway.setup_purchase(amount * 100, options)
      invoice = Invoice.create(
          token: response.token,
          user: user,
          amount: amount
      )
      gateway.redirect_url_for response.token
    end

    def purchase(options = {})
      # Throw exception if the token param is non-exist
      invoice = Invoice.find_by! token: options[:token]

      # Checkout
      response = gateway.purchase(invoice.amount * 100, options)
      if response.success?
        invoice.complete(response.params['transaction_id'])
      end
    rescue Exception => e
      invoice.completed = false
    ensure
      invoice.save
      invoice
    end

    def gateway
      ActiveMerchant::Billing::PaypalExpressGateway.new PAYPAL_CONFIG
    end

  end

end