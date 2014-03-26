=begin
  t.integer   :tipster_id
  t.string    :range |last-week, last-month, last-n-months, year ...|
  t.integer   :profit
  t.integer   :yield
  t.integer   :number_of_tips
  t.float     :hit_rate
  t.float     :avg_odds
  t.integer   :number_profitable_months
  t.integer   :number_join_months
  t.datetime  :update_at
=end
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