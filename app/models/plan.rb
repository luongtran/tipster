class Plan < ActiveRecord::Base

  class << self
  end

  def free?
    self.price.zero?
  end
end
