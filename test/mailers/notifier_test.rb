require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "notify_subscriber" do
    mail = Notifier.notify_subscriber
    assert_equal "Notify subscriber", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
