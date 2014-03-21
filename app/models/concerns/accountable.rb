# Use for tipster and subscriber classes
module Accountable
  extend ActiveSupport::Concern

  included do
    has_one :account, as: :rolable
    accepts_nested_attributes_for :account
    delegate :email, to: :account, prefix: false
  end

end