module DateUtils
  class << self
    def previous_week_date_range
      today = Date.today
      today.prev_week..today.prev_week.end_of_week
    end
  end
end
