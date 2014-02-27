class TipsterAbility < UserAbility

  def initialize(user)
    super(user)
    can [:new, :create], Tip
  end
end