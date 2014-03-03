class Subscriber < ActiveRecord::Base
  DEFAULT_BIRTHDAY = '1990-01-01'
  KNOW_WEBSITE_FROM_LIST = %w(other sponsoring advertising social_network)

  # If we have more questions, please add them at the bottom of the list
  SQ_BORN_CITY = 0
  SQ_COLOR_PREFER = 1
  SQ_PET_NAME = 2
  SQ_FAVORITE_ACTOR_OR_SINGER = 3
  SQ_MOTHER_MAIDEN_NAME = 4

  SECRET_QUESTIONS_MAP = {
      SQ_BORN_CITY => 'What is your born city?',
      SQ_COLOR_PREFER => 'What is your color preferred?',
      SQ_PET_NAME => 'What is the name of your pet?',
      SQ_FAVORITE_ACTOR_OR_SINGER => 'What is your actor or favorite singer?',
      SQ_MOTHER_MAIDEN_NAME => 'What is the maiden name of your mother?'
  }
  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  has_one :account, as: :rolable
  has_many :authorizations, dependent: :destroy
  has_one :subscription

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :first_name, :last_name, presence: true, format: {with: /\A([a-z]|[A-Z])/}, length: {minimum: 2}
  validates_presence_of :birthday, :civility, :mobile_phone, :secret_question, :answer_secret_question, on: :update
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

  def full_name
    "#{self.first_name} #{self.last_name}".titleize
  end

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
