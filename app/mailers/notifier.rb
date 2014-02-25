class Notifier < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.notify_subscriber.subject
  #
  def notify_subscriber
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
