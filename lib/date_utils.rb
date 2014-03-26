module DateUtils
  class << self
    # Return the date range of previous week from today
    def previous_week_date_range
      today = Date.today
      today.prev_week..today.prev_week.end_of_week
    end

    def in_time_zone(time, format, timezone = Time.zone_default)
      time.in_time_zone(timezone).strftime(format)
    end
  end
end
