# == Schema Information
#
# Table name: subscribers
#
#  id                         :integer          not null, primary key
#  first_name                 :string(255)
#  last_name                  :string(255)
#  nickname                   :string(255)
#  gender                     :boolean          default(TRUE)
#  civility                   :string(255)
#  birthday                   :date
#  address                    :string(255)
#  city                       :string(255)
#  country                    :string(255)
#  zip_code                   :string(255)
#  mobile_phone               :string(255)
#  telephone                  :string(255)
#  favorite_beting_website    :string(255)
#  know_website_from          :string(255)
#  secret_question            :integer
#  answer_secret_question     :string(255)
#  receive_info_from_partners :boolean          default(FALSE)
#  receive_tip_methods        :string(255)
#  created_by_omniauth        :boolean          default(FALSE)
#  created_at                 :datetime
#  updated_at                 :datetime
#

class Subscriber < ActiveRecord::Base
  include Humanizer
  require_human_on :update, :unless => :bypass_humanizer


  PROFILE_ATTRS = [:first_name, :last_name, :nickname, :gender, :receive_tip_methods, :birthday, :address, :city, :country, :zip_code, :mobile_phone,
                   :telephone, :favorite_beting_website, :know_website_from, :secret_question, :answer_secret_question, :receive_info_from_partners,
                   :humanizer_answer, :humanizer_question_id]
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
  attr_accessor :validate_with_paid_account, :create_with_only_account, :bypass_humanizer

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
  validates_date :birthday, :before => lambda { 16.years.ago + 1.day }, allow_blank: true
  validates :first_name, :last_name, :birthday, presence: true, length: {minimum: 2}, unless: :create_with_only_account
  validates_presence_of :mobile_phone, :telephone, :secret_question, :answer_secret_question, :country, if: :validate_with_paid_account

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================
  #before_validation :format_phone_number, on: :update
  delegate :email, to: :account, prefix: false
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
      subscriber.account.skip_confirmation!
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
  def apply_plan(plan)
    self.subscription.delete if self.subscription
    subscription = self.build_subscription(
        plan: plan,
        active: true,
        active_at: Time.now,
        expired_at: (Time.now + plan.period.month)
    )
    subscription.save
  end

  def has_active_subscription?
    self.subscription && self.subscription.active?
  end

  def update_receive_tips_method(methods)
    self.update_column :receive_tip_methods, methods.join(',')
  end

  def receive_tip_by_email?
    self.receive_tip_methods && self.receive_tip_methods.split(',').include?('by_email')
  end

  def receive_tip_by_sms?
    self.receive_tip_methods && self.receive_tip_methods.split(',').include?('by_sms')
  end

  def full_name
    "#{self.first_name} #{self.last_name}".titleize
  end

  def profile_completed?
    self.profile && self.profile.valid?
  end

  def already_has_subscription?
    self.subscription && !self.subscription.plan.free? && self.subscription.active == true
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
