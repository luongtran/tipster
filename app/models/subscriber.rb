class Subscriber < User
  devise :registerable
  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  has_many :authorizations, foreign_key: :user_id, dependent: :destroy
  has_one :subscription, foreign_key: :user_id

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def create_from_auth_info(auth)
      subscriber = new(
          :email => auth[:info][:email],
          :first_name => auth[:info][:first_name],
          :last_name => auth[:info][:last_name],
          :password => Devise.friendly_token[0, 20]
      )
      subscriber.save!
      subscriber
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def profile_completed?
    self.profile && self.profile.valid?
  end

  def already_has_subscription?
    self.subscription && self.subscription.active == true
  end

  # Add Facebook, Google+ identify
  def add_authorization(auth)
    self.authorizations << Authorization.build_from_oauth(auth)
  end

  #Check user using coupon code

  def using_coupon?
    self.coupon_codes.present? && self.subscription
  end
end
