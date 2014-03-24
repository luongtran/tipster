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
  PAYMENT_STATUS = ["Initial","Pending","Completed","Expired"]
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
  has_many :additional_tipsters, :through => :subscription_tipsters,
           :class_name => "Tipster",
           :source => :tipster,
           :conditions => ['subscription_tipsters.is_primary = ?', false]

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
    (self.active_tipsters.count + count) <= self.plan.number_tipster + Subscription::MAX_ADDITIONAL_TIPSTERS
  end

  def calculator_price
    if self.is_one_shoot
      one_shoot_price
    else
      monthly_price
    end
  end

  def one_shoot_price
    price = (self.plan.price.to_f * self.plan.period) + added_tipster * self.plan.adding_price
    if self.using_coupon
      price -= 3
    end
    return price.round(2)
  end

  def monthly_price
    price = self.plan.price.to_f + added_tipster * self.plan.adding_price
    if self.using_coupon
      price -= 3
    end
    return price.round(2)
  end

  # =========NEED TO CALCULATING AGAIN  =======
  def added_price
    price = self.added_tipster * self.plan.adding_price
    return price.round(2)
  end

  def tipsters_size
    self.active_tipsters.size
  end
  def need_to_paid
    if self.active
      expires = self.inactive_tipsters.size
      if expires > 0
        amount = expires * self.plan.adding_price
      else
        amount = 0
      end
    else
      amount = self.calculator_price
      # Bla bla !
    end
    amount
  end

  def added_tipster
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

  def insert_tipster(tipsters)
    tipsters.each do |tipster|
      unless self.tipsters.include?(tipster)
        self.tipsters << tipster
      end
    end
    self.save
  end

  def can_change_tipster?
    self.active && self.active_at > 1.days.ago || (self.active_at.strftime('%d').to_i == Time.now.strftime('%d') && self.expired_at > Time.now)
  end


  def remove_tipster(id)
    self.tipsters.delete(id)
  end

  # Only set when init payment

  def set_primary(id)
    if Tipster.exists? id && self.tipster_ids.include?(id)
      if self.subscription_tipsters.present?
        self.subscription_tipsters.each do |x|
          x.update_column(:is_primary, false)
        end
        self.subscription_tipsters(tipster_id: id).first.update_column(:is_primary, true)
        {success: true}
      else
        {success: false, error: 'Subscription tipster is empty!'}
      end
    else
      #Error tipster id not valid
      {success: false, error: 'Tipster id not exit'}
    end
  end

  def primary_tipster
    data = self.subscription_tipsters.primary_tipster.first
    if data
      ret = data.tipster
    else
      self.set_primary(self.tipsters.first.id)
    end
    ret
  end

  def generate_paykey
    if self.active
      # generate for addition tipsters
      tmp = self.inactive_tipster_ids
      tipster_ids = tmp.join(',')
      paykey = Digest::MD5.hexdigest("#{self.id} #{Time.now.to_i} #{Time.now.usec}")
      payment = self.payments.build(amount: self.need_to_paid, paykey: paykey, paid_for: 'additional', tipster_ids: tipster_ids)
    else
      paykey = Digest::MD5.hexdigest("#{self.id} #{Time.now.to_i} #{Time.now.usec}")
      payment = self.payments.build(amount: self.calculator_price, paykey: paykey, paid_for: 'subscription')
    end
    if payment.save
      {success: true, paykey: paykey}
    else
      {success: false, message: payment.errors.full_message.join(' ')}
    end
  end

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def check_expired
      all.each do |subscription|
        if subscription.created_at.to_date >= Time.now.to_date
          puts "WTF = = = = !!!"
          puts "IS #{subscription.id}"
        end
      end
    end
  end

end
