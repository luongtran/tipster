class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :user

  has_many :tipsters, through: :subscriber_tipsters

  has_many :subscriber_tipsters
  has_many :payments

  # TODO, I don't see any validations here ???

  def calculator_price
    self.tipsters.size > self.plan.number_tipster ? bonus = self.tipsters.size - self.plan.number_tipster : bonus = 0
    self.plan.price.to_f + bonus * 9.9
  end

  def one_shoot_price
    self.plan.price.to_f
  end

end
