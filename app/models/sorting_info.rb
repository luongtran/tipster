class SortingInfo
  INCREASE = 'asc'
  DECREASE = 'desc'
  DEFAULT_SORT_DIRECTION = DECREASE
  DEFAULT_SORT_FIELD = 'id'

  attr_accessor :sort_by, :direction

  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value.downcase)
    end
    return self
  end

  def initialize(sort_string, options = {})
    if sort_string.present?
      sort_direction = sort_string.split('_').last
      sort_field = sort_string.gsub(/(_desc|_asc)/, '')
    else
      sort_field = options[:default_sort_by] || DEFAULT_SORT_FIELD
      sort_direction = options[:default_sort_direction] || DEFAULT_SORT_DIRECTION
    end
    @sort_by = sort_field
    @direction = sort_direction
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
