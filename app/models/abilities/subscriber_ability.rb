class SubscriberAbility < UserAbility

  def initialize(user)
    super(user)
    cannot [:new, :create], Tip
  end
end