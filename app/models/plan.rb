# coding: utf-8
class Plan < ActiveRecord::Base

  class << self
  end

  def free?
    self.price.zero?
  end

  def price_in_string(currency = '€')
    "#{currency}#{self.price}"
  end
end
