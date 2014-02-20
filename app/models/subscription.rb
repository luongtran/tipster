class Subscription < ActiveRecord::Base
  has_many :tipsters, through: :subscriber_tipsters
  belongs_to :plan
  has_many :subscriber_tipsters
  belongs_to :user
  has_many :payments

  def calculator_price
    puts "PLAN PRICE #{self.plan.price} TIPSTER OFFER #{(self.tipsters.size - 1) * 9.9}"
    return self.plan.price.to_f + (self.tipsters.size - 1) * 9.9
  end
end
