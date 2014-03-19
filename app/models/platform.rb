# == Schema Information
#
# Table name: platforms
#
#  id   :integer          not null, primary key
#  code :string(255)      not null
#  name :string(255)      not null
#

class Platform < ActiveRecord::Base
  validates :code, :name, uniqueness: {case_sensitive: false}
end
