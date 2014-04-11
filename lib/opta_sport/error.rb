module OptaSport
  class Error
    attr_accessor :message, :url, :time

    def initialize(attrs = {})
      attrs ||= {}
      attrs.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
      return self
    end

    def log_format
      "\n==== WARNING: OptaSport Error ===============\n" +
          "- Message: #@message\n" +
          "- URL: #@url\n" +
          "- At: #@time\n" +
          "=============================================\n"
    end
  end
end