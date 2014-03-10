# == Schema Information
#
# Table name: admins
#
#  id         :integer          not null, primary key
#  full_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Admin < ActiveRecord::Base
  has_one :account, as: :rolable
end
