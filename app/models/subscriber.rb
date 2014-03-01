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

class Subscriber < User
  devise :registerable
  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :twitter]
  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  has_many :authorizations, foreign_key: :user_id, dependent: :destroy
  has_one :subscription, foreign_key: :user_id

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def create_from_auth_info(auth)
      subscriber = new(
          :email => auth[:info][:email],
          :first_name => auth[:info][:first_name],
          :last_name => auth[:info][:last_name],
          :password => Devise.friendly_token[0, 20]
      )
      subscriber.save!
      subscriber
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

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
end
