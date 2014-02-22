class Subscription < ActiveRecord::Base

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :plan
  belongs_to :subscriber, foreign_key: :user_id, class_name: 'Subscriber'

  has_many :tipsters, through: :subscriber_tipsters
  has_many :subscriber_tipsters
  has_many :payments

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :subscriber, :plan, presence: true

  delegate :title, :to => :plan, :prefix => true # Example using: self.plan_title

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
