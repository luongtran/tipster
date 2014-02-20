class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :user

  has_many :tipsters, through: :subscriber_tipsters

  has_many :subscriber_tipsters
  has_many :payments

  def calculator_price
    self.plan.price.to_f + (self.tipsters.size - self.plan.number_tipster) * 9.9
  end

  def one_shoot_price
    self.plan.price.to_f
  end

end
