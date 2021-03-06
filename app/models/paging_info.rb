# Include information for pagination.
class PagingInfo
  attr_accessor :page, :page_size

  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
    return self
  end
end
