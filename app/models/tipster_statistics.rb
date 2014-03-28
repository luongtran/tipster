class TipsterStatistics < ActiveRecord::Base
  belongs_to :tipster

  class BaseStatistics
    attr_accessor :from, :to, :range,
                  :profit, :number_correct_tips,
                  :total_amount, :total_odds, :number_of_tips,
                  :yield, :hit_rate, :avg_odds,
                  :profit_per_dates

    def initialize(attrs = {})
      attrs ||= {}
      attrs.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
      # Initial values
      @profit = 0
      @total_odds = 0
      @number_of_tips = 0
      @number_correct_tips = 0
      @total_amount = 0
      @profit_per_dates = []
      return self
    end

    def cal
      #results[range_key].yield = (_profit * 100/_total_amount.to_f).round(0)
      #results[range_key].hit_rate = (_correct_tips * 100/_number_of_tips.to_f).round(1)
      #results[range_key].avg_odds = (_total_odds/_number_of_tips.to_f).round(1)
    end
  end

  RANKING_RANGES = [
      OVERALL = 'overall',
      LAST_12_MONTHS = 'last_12_months',
      LAST_6_MONTHS = 'last_6_months',
      LAST_3_MONTHS = 'last_3_months',
      LAST_MONTH = 'last_month'
  ]
  # Extra ranking range
  RANKING_RANGES_EX = [
      PREVIOUS_WEEK = 'previous_week',
  ]

  class << self
    def date_range_parser(range_in_string)
      end_date = Date.today
      start_date = case range_in_string
                     when PREVIOUS_WEEK
                       Date.today.prev_week
                     when LAST_MONTH
                       30.days.ago
                     when LAST_3_MONTHS
                       90.days.ago
                     when LAST_6_MONTHS
                       180.days.ago
                     when LAST_12_MONTHS
                       365.days.ago
                     when OVERALL
                       # The join date of the first tipster account
                       Tipster.order("created_at asc").first.created_at.to_date
                     else
                       90.days.ago
                   end
      start_date..end_date
    end

    def perform_statistics_for(tipster)
      ts = new(tipster: tipster)
      statistics_data = {}

      tips = tipster.finished_tips # Get overall finished tips
      statistics_data[:last_x_months] = get_last_n_months_statistics(tips)
      statistics_data[:monthly] = get_monthly_statistics(tips)
      statistics_data[:sports] = get_sports_statistics(tips)
      statistics_data[:countries_competitions] =get_countries_competitions_statistics(tips)
      statistics_data[:odds] = get_odds_statistics(tips)
      statistics_data[:type_of_bets] = get_type_of_bets_statistics(tips)

      ts[:updated_at] = DateTime.now
      ts.save
    end

    # Calculate previous week and last-n-months
    def get_last_n_months_statistics(tips = [])
      results = {}
      # Prepare date ranges
      RANKING_RANGES.each do |range_key|
        date_range = date_range_parser(range_key)
        bs = BaseStatistics.new(
            from: date_range.first,
            to: date_range.last,
            range: date_range
        )
        results[range_key] = bs
      end

      # Group published date and sort increase
      date_with_tips = tips.group_by(&:published_date)

      date_with_tips = date_with_tips.sort_by { |published_date, tips| (published_date.to_time.to_i) }

      # Loop per dates, ordered by increase
      #_total_tips = tips.size

      #_total_amount = 0
      _total_profit = 0 # incremental
      #_correct_tips = 0 # incremental
      #_total_odds = 0 # incremental
      #_number_of_tips = 0

      date_with_tips.each do |published_date, tips|

        profit_on_current_date = 0
        total_amount_of_current_date = 0
        total_odds_of_current_date = 0
        number_correct_tips_current_date = 0
        number_tips_of_current_date = tips.size

        # Loop tips in date
        tips.each do |tip|
          total_amount_of_current_date += tip.amount
          total_odds_of_current_date += tip.odds
          # Money Money Money
          money_of_tip = 0
          if tip.correct?
            number_correct_tips_current_date += 1
            money_of_tip= (tip.amount*(tip.odds - 1)).round(0)
          else
            money_of_tip= (-tip.amount)
          end
          profit_on_current_date += money_of_tip
        end
        # Update statistics_obj
        results.each do |range_key, statistics_obj|
          if statistics_obj.range.cover?(published_date)
            results[range_key].number_of_tips += number_tips_of_current_date
            results[range_key].total_odds += total_odds_of_current_date
            results[range_key].number_correct_tips += number_correct_tips_current_date
            results[range_key].total_amount += total_amount_of_current_date
            results[range_key].profit += profit_on_current_date
            results[range_key].profit_per_dates << {'date' => published_date, 'profit' => results[range_key].profit}
          end
          # TODO: it's different with previous-week
        end
      end
      results
    end

    def get_monthly_statistics(tipster)
    end

    def get_sports_statistics(tipster)
    end

    def get_countries_competitions_statistics(tipster)
    end

    def get_odds_statistics(tipsters)
    end

    def get_type_of_bets_statistics(tiptser)
    end
  end

  SAMPLE = {
      tipster_id: 1,
      data: {
          'last_x_months' => {
              'previous_week' => {
                  'from' => 'from date',
                  'to' => 'to date',
                  'name' => 'Jan 2014',
                  'profit' => 1,
                  'yield' => 2,
                  'hit_rate' => 3,
                  'avg odds' => 4,
                  'number_of_tips' => 5
              },
              'last_month' => {
                  'name' => 'Jan 2014',
                  'profit' => 1,
                  'yield' => 2,
                  'hit_rate' => 3,
                  'avg_odds' => 4,
                  'number_of_tips' => 5
              }
              #'last-month',
              #'last-3-months',
              #'last-6-months',
              #'last-12-months',
          },
          'monthly' => [
              {
                  'name' => 'Jan 2014',
                  'profit' => 1,
                  'yield' => 2,
                  'hit_rate' => 3,
                  'avg_odds' => 4,
                  'number_of_tips' => 5
              },
          # ...
          ],
          'sports' => [
              {
                  'sport_code' => 'football',
                  'sport_name' => 'Football',
                  'percentage' => '10',
                  #'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
              }
          ],
          'countries_competitions' => [
              {
                  'country_code' => 'EN',
                  'percentage' => '10'
              }
          ],
          'type_of_bets' => [
              {
                  'sport_code' => 'football',
                  'bet_name' => 'Match odds'
              }
          ],
          'odds' => [
              {
                  'range' => '3.0 - 6.0',
                  'profit' => '123',
                  'yield' => '35',
                  'number_of_tips' => '100',
                  'hit_rate' => '15',
                  'avg_odds' => '3.2'
              }
          ],
          'profitable_months' => 3,
          'join_months' => 8
      }, # End data
      'update_at' => DateTime.now
  }

  UPDATE_PERIOD = 2.hours

  attr_accessor :tipster, :range, :profit, :yield, :number_of_tips, :hit_rate, :avg_odds, :profit_per_months, :profit_per_days

  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
    return self
  end

  class << self

  end
end