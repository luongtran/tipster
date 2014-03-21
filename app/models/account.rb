# == Schema Information
#
# Table name: accounts
#
#  id                     :integer          not null, primary key
#  rolable_id             :integer
#  rolable_type           :string(255)
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
#

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
    true
  end

  # ==============================================================================
  # PRIVATE METHODS
  # ==============================================================================

end
