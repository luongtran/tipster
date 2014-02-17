class Authorization < ActiveRecord::Base

  belongs_to :subscriber, :foreign_key => :user_id

  validates :user_id, :uid, :provider, :presence => true
  validates_uniqueness_of :uid, :scope => :provider

  class << self
    def find_or_initialize_from_oauth(auth)
      conditions = {provider: auth['provider'], uid: auth['uid']}
      where(conditions).first || new(conditions.merge(avatar_url: auth[:info][:image]))
    end
  end
end
