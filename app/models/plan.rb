# == Schema Information
#
# Table name: plans
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  title                  :string(255)
#  reception_delay        :integer          default(3600)
#  description            :text
#  pause_ability          :boolean          default(TRUE)
#  switch_tipster_ability :boolean          default(TRUE)
#  profit_guaranteed      :boolean          default(TRUE)
#  discount               :float            default(0.0)
#  price                  :float
#  number_tipster         :integer
#  period                 :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class Plan < ActiveRecord::Base

  class << self
  end

  def free?
    self.price.zero?
  end
end
