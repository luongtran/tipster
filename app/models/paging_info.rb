# Include information for pagination.
class PagingInfo
  attr_accessor :page_id, :page_size, :sort_string, :sort_criteria

  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
    return self
  end
end
