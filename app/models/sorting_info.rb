# Include information for sorting.
class SortingInfo
  INCREASE = 'asc'
  DECREASE = 'desc'
  attr_accessor :sort_by, :direction

  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value.downcase)
    end
    return self
  end

  def to_string
    "#{self.sort_by}_#{self.direction}"
  end

  def increase?
    self.direction == INCREASE
  end

  def decrease?
    self.direction == DECREASE
  end
end
