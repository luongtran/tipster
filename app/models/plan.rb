class Plan < ActiveRecord::Base

  class << self
    # Params contains: plan_id, tipster_count, discount code
    def calculate_amount(params = {})
      175
    end
  end

  def free?
    self.price.zero?
  end
end
