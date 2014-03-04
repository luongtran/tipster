class RegistrationService
  def create_subscriber(subscriber_params)
    Subscriber.create(subscriber_params)
  end
end