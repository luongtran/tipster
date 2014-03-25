class TipsterStatistics
  attr_accessor :tipster, :range, :profit, :yield, :number_of_tips, :hit_rate, :avg_odds, :profit_per_months, :profit_per_days

  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
    return self
  end
end