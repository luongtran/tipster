class Subscription < ActiveRecord::Base

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :plan
  belongs_to :subscriber, foreign_key: :user_id, class_name: 'Subscriber'

  has_many :subscriptions_tipsters
  has_many :payments
  has_many :tipsters,
           :through => :subscriptions_tipsters,
           :conditions => "active => '1'",
           :order => :email
  has_many :inactive_tipsters,
           :conditions => "active => '0'",
           :through => :subscriptions_tipsters,
           :source => :tipsters,
           :order => :created_at
  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :subscriber, :plan, presence: true

  delegate :title, :to => :plan, :prefix => true # Example using: self.plan_title
  def payment_completed?
    self.payments.present? && self.active
  end
  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================
  def calculator_price
    adder =  self.tipsters.size > self.plan.number_tipster ? self.tipsters.size - self.plan.number_tipster : 0
    (self.plan.price.to_f + adder * ADDING_TIPSTER_PRICE) * self.plan.period
  end

  def one_shoot_price
    self.plan.price.to_f
  end
end
