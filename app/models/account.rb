class Account < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :omniauthable, :confirmable
  # :lockable, :timeoutable and :omniauthable , :session_limitable

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :rolable, polymorphic: true


  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def build_with_rolable(params, rolable_class)
      acc = self.new(params)
      acc.rolable = rolable_class.new
      acc
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def update_account(params)
    self.update_without_password(params)
  end

  def active_for_authentication?
    super && false
  end

  # ==============================================================================
  # PROTECTED METHODS
  # ==============================================================================


  # ==============================================================================
  # PRIVATE METHODS
  # ==============================================================================

end
