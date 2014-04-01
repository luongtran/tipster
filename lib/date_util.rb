module DateUtil
  class << self
    # Return the date range of previous week from today
    def previous_week_date_range
      today = Date.today
      today.prev_week..today.prev_week.end_of_week
    end

    def in_time_zone(time, format, timezone = Time.zone_default)
      time.in_time_zone(timezone).strftime(format)
    end

    # Return an array of the first days of months from the given date to today
    def first_days_of_months_so_far_from(from_date)
      dates = []
      first_day_of_first_month = from_date.beginning_of_month
      first_day_of_last_month = Date.today.beginning_of_month
      tmp_date = first_day_of_first_month
      while tmp_date <= first_day_of_last_month
        dates << tmp_date
        tmp_date = tmp_date.next_month
      end
      dates
    end

    def date_range_of_month_for(date)
      date.beginning_of_month..date.end_of_month
    end

    def name_of_month_for(date)
      date.strftime(I18n.t("date.monthly_statistics"))
    end
  end
end
