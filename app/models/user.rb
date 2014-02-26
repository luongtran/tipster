class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :twitter]

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  has_one :profile, dependent: :destroy
  has_many :invoices
  has_many :coupon_codes
  accepts_nested_attributes_for :profile

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :first_name, :last_name, :presence => true

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

  # ==============================================================================
  # PROTECTED METHODS
  # ==============================================================================
  #protected

  # ==============================================================================
  # PRIVATE METHODS
  # ==============================================================================
  #private

end
