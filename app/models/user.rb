class User < ActiveRecord::Base
  # TODO, if birthday is required so do we need to validate the age of user ?
  DEFAULT_BIRTHDAY = '1970-01-01'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :first_name, :last_name, :presence => true
  validates_date :birthday, :message => 'birthday is invalid'

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================
  before_validation :init_default_birthday

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

  # ==============================================================================
  # PROTECTED METHODS
  # ==============================================================================
  #protected

  # ==============================================================================
  # PRIVATE METHODS
  # ==============================================================================
  private

  def init_default_birthday
    self[:birthday] ||= DEFAULT_BIRTHDAY
  end
end
