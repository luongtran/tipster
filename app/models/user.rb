class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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
  #private

end
