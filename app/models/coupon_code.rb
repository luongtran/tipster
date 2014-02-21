class CouponCode < ActiveRecord::Base

  SOURCES = [FACEBOOK = 'facebook', TWITTER = 'twitter']

  belongs_to :user

  validates :user, :code, presence: true

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def create_for_user(user, source = nil)
      cc = new(
          user: user,
          code: generate_unique_code(user),
          source: source
      )
      cc.save!
      cc
    end

    def generate_unique_code(user)
      Digest::MD5.hexdigest("#{user.id} #{Time.now.to_i} #{Time.now.usec}")
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def mark_used
    self.update_attributes is_used: true, used_at: DateTime.now
  end

end
