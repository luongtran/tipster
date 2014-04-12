class Authorization < ActiveRecord::Base

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :subscriber

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :subscriber, :uid, :provider, presence: true
  validates_uniqueness_of :uid, scope: :provider

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def build_from_oauth(auth)
      new(
          provider: auth['provider'],
          uid: auth['uid'],
          avatar_url: auth['info']['image']
      )
    end

    def find_from_oauth(auth)
      where(provider: auth['provider'], uid: auth['uid']).first
    end
  end
end
