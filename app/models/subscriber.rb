class Subscriber < ActiveRecord::Base
  include Humanizer
  require_human_on :update, :unless => :bypass_humanizer

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

  # Indicator to validate more attributes if subscriber is paid account
  attr_accessor :validate_with_paid_account, :bypass_humanizer

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  has_one :account, as: :rolable
  has_one :subscription
  has_many :authorizations, dependent: :destroy
  has_many :coupon_codes
  accepts_nested_attributes_for :account

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates_date :birthday, :before => lambda { 16.years.ago }, allow_blank: true
  validates :first_name, :last_name, :birthday, presence: true, length: {minimum: 2}, on: :update
  validates_presence_of :mobile_phone, :telephone, :secret_question, :answer_secret_question, :country, on: :update, if: :validate_with_paid_account

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================
  #before_validation :format_phone_number, on: :update

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def create_from_auth_info(auth)
      subscriber = new(
          first_name: auth[:info][:first_name],
          last_name: auth[:info][:last_name],
          account_attributes: {
              :email => auth[:info][:email],
              :password => Devise.friendly_token[0, 20]
          },
          created_by_omniauth: true
      )
      subscriber.save!
      subscriber
    end

    def register(params)
      subscriber = new(params)
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def has_active_subscription?
    self.subscription && self.subscription.active?
  end

  def update_receive_tips_method(methods)
    self.update_column :receive_tip_methods, methods.join(',')
  end

  def receive_tip_by_email?
    self.receive_tip_methods.split(',').include? 'by_email'
  end

  def receive_tip_by_sms?
    self.receive_tip_methods.split(',').include? 'by_sms'
  end

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

  private
  def format_phone_number

  end
end
