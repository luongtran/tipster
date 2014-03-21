# == Schema Information
#
# Table name: subscriptions
#
#  id            :integer          not null, primary key
#  subscriber_id :integer
#  plan_id       :integer
#  using_coupon  :boolean          default(FALSE)
#  active        :boolean          default(FALSE)
#  active_at     :datetime
#  expired_at    :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  is_one_shoot  :boolean          default(FALSE)
#

class Subscription < ActiveRecord::Base
  MAX_ADDITIONAL_TIPSTERS = 2
  ADDING_TIPSTER_PERCENT = 0.4
  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :plan
  belongs_to :subscriber
  has_many :payments
  has_many :subscription_tipsters, dependent: :destroy
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
  def set_active
    self.update_attributes(
        active: true,
        active_at: Time.now,
        expired_at: Time.now + self.plan.period.month
    )
  end

  def able_to_add_more_tipsters?(count = 1)
    (self.active_tipsters.count + count) <= self.plan.number_tipster
  end

  def calculator_price
    if self.is_one_shoot
      one_shoot_price
    else
      monthly_price
    end
  end

  def one_shoot_price
    price = (self.plan.price.to_f * self.plan.period)  + adder_tipster * self.plan.adding_price
    if self.using_coupon
      price -= 3
    end
    return price.round(2)
  end

  def monthly_price
    price = (self.plan.price.to_f + adder_tipster * (self.plan.price * ADDING_TIPSTER_PERCENT))
    if self.using_coupon
      price -= 3
    end
    return price.round(3)
  end
# =========NEED TO CALCULATING AGAIN  =======
  def adder_price
    price = self.adder_tipster * (self.plan.price * ADDING_TIPSTER_PERCENT) * self.plan.period
    if self.using_coupon
      price -= 3
    end
    return price.round(3)
  end

  def adder_tipster
    if self.active? && !self.plan.free?
      add = self.tipsters.size > [self.active_tipsters.size, self.plan.number_tipster].max ? self.tipsters.size - [self.active_tipsters.size, self.plan.number_tipster].max : 0
    else
      add = self.tipsters.size > self.plan.number_tipster ? self.tipsters.size - self.plan.number_tipster : 0
    end
    add
  end

  def change_tipster(tipster)
    self.subscription_tipsters.where(tipster_id: tipster.id).each do |t|
      t.try(:set_active)
    end
  end

  def insert_tipster(tipster)
    self.tipsters << tipster
    self.save
    self.subscription_tipsters.each do |t|
      t.try(:set_active)
    end
  end

  def can_change_tipster?
    self.active && self.active_at > 1.days.ago || (self.active_at.strftime('%d').to_i == Time.now.strftime('%d') && self.expired_at > Time.now)
  end


  def remove_tipster(id)
    self.tipsters.delete(id)
  end
end
