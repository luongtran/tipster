class Subscriber < User

  # ASSOCIATIONS
  has_many :authorizations, :foreign_key => :user_id

  # CLASS METHODS
  class << self
    def create_from_auth_info(auth, identity)
      subscriber = new(
          :email => auth[:info][:email],
          :first_name => auth[:info][:first_name],
          :last_name => auth[:info][:last_name],
          :password => Devise.friendly_token[0, 20]
      )
      transaction do
        subscriber.save!
        identity.subscriber = subscriber
        identity.save!
      end
      subscriber
    end
  end
end