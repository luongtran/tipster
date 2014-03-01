# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  type                   :string(255)
#  active                 :boolean          default(TRUE)
#  sport_id               :integer
#  string                 :unique_session_i
#  unique_session_id      :string(20)
#

# Tipster
# Single Table Inherit

class User < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  # :confirmable, :lockable, :timeoutable and :omniauthable , :session_limitable

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  has_one :profile, dependent: :destroy
  has_many :invoices
  has_many :coupon_codes
  accepts_nested_attributes_for :profile
  mount_uploader :avatar, AvatarUploader
  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :first_name, :last_name, presence: true, format: {with: /\A([a-z]|[A-Z])/}, length: {minimum: 2}

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self

  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def name
    "#{self.first_name} #{self.last_name}".titleize
  end

  def find_or_initial_profile
    self.profile || Profile.new(:user => self)
  end

  def update_profile(params)
    profile = self.find_or_initial_profile
    profile.assign_attributes(params)
    profile.save
    profile
  end

  def update_account(params)
    self.update_without_password(params)
  end

  # Define 3 instance methods: admin?, subscriber? and tipster?
  %w(Admin Tipster Subscriber).each do |klass|
    define_method "#{klass.downcase}?" do
      self.is_a? klass.constantize
    end
  end

  # ==============================================================================
  # PROTECTED METHODS
  # ==============================================================================
  #protected


  # ==============================================================================
  # PRIVATE METHODS
  # ==============================================================================
  private

end
