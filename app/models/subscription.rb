# == Schema Information
#
# Table name: subscriptions
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  plan_id      :integer
#  active       :boolean          default(FALSE)
#  active_date  :datetime
#  expired_date :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class Subscription < ActiveRecord::Base

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :plan
  belongs_to :subscriber, foreign_key: :user_id, class_name: 'Subscriber'
  has_many :payments
  has_many :subscription_tipsters
  has_many :tipsters, :through => :subscription_tipsters
  has_many :active_tipsters, :through => :subscription_tipsters,
           :class_name => "Tipster",
           :source => :tipster,
           :conditions => ['subscription_tipsters.active = ?', true]
  has_many :inactive_tipsters, :through => :subscription_tipsters,
           :class_name => "Tipster",
           :source => :tipster,
           :conditions => ['subscription_tipsters.active = ?', false]


  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :subscriber, :plan, presence: true

  delegate :title, :to => :plan, :prefix => true # Example using: self.plan_title

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def calculator_price
    (self.plan.price.to_f + adder_tipster * ADDING_TIPSTER_PRICE) * self.plan.period
  end

  def adder_tipster
    self.tipsters.size > self.plan.number_tipster ? self.tipsters.size - self.plan.number_tipster : 0
  end

  def one_shoot_price
    self.plan.price.to_f
  end

  def remove_tipster(id)
    self.tipsters.delete(id)
  end
end
