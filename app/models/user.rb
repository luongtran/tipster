class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  # VALIDATIONS
  validates :first_name, :last_name, :presence => true

  # CALLBACKS

  before_create :init_default_birthday

  # CLASS METHODS
  class << self

  end

  # INSTANCE METHODS
  def name
    "#{self.first_name} #{self.last_name}".titleize
  end

  # PROTECTED METHODS
  #protected

  # PRIVATE METHODS
  private

  def init_default_birthday
    self[:birthday] = '1970-01-01' unless self.birthday
  end
end
