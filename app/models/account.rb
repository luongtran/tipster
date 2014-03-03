class Account < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :omniauthable
  # :confirmable, :lockable, :timeoutable and :omniauthable , :session_limitable

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :rolable, polymorphic: true
  has_many :invoices
  has_many :coupon_codes

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :crop_avatar

  def crop_avatar
    avatar.recreate_versions! if crop_x.present?
  end

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self

  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
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
  private

end
