class Admin < ActiveRecord::Base
  has_one :account, as: :rolable
  accepts_nested_attributes_for :account
end
