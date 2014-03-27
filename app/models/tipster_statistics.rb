class TipsterStatistics < ActiveRecord::Base
  belongs_to :tipster
  validates_presence_of :tipster

  class StatisticsNumber
    attr_accessor :from, :to, :range,
                  :profit, :number_correct_tips,
                  :total_amount, :total_odds, :number_of_tips,
                  :yield, :hit_rate, :avg_odds,
                  :profit_per_dates

    def initiallize
    end
  end

  class BaseStatistics
    attr_accessor :from, :to, :range,
                  :profit, :number_correct_tips,
                  :total_amount, :total_odds, :number_of_tips,
                  :yield, :hit_rate, :avg_odds,
                  :profit_per_dates

    class << self
      def initial_from_json(json_string)
      end
    end

    def initialize(range)
      @range = range
      # Initial values
      @profit = 0
      @total_odds = 0
      @number_of_tips = 0
      @number_correct_tips = 0
      @total_amount = 0
      @yield = 0
      @hit_rate = 0
      @avg_odds = 0
      @profit_per_dates = []
      self
    end

    # Calculate more values
    def composite
      unless @number_of_tips.zero?
        @yield = (@profit * 100/@total_amount.to_f).round(0)
        @hit_rate = (@number_correct_tips * 100/@number_of_tips.to_f).round(1)
        @avg_odds = (@total_odds/@number_of_tips.to_f).round(1)
      end
      self
    end

    def format_for_store
      {
          from: @range.first,
          to: @range.last,
          profit: @profit,
          yield: @yield,
          hit_rate: @hit_rate,
          avg_odds: @avg_odds
      }
    end

  end

  class LastNMonthStatistics
  end

  class SportStatistics
  end

  class CountryCompetitionStatistics
  end

  class OddStatistics
  end
  class BetTypeStatistics
  end

  RANKING_RANGES = [
      OVERALL = 'overall',
      LAST_12_MONTHS = 'last_12_months',
      LAST_6_MONTHS = 'last_6_months',
      LAST_3_MONTHS = 'last_3_months',
      LAST_MONTH = 'last_month'
  ]
  # Extra ranking range
  EXTRA_RANKING_RANGES = [
      PREVIOUS_WEEK = 'previous_week',
  ]

  ODDS_RANGES = [

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
      statistics_data[:last_n_months] = get_last_n_months_statistics(tipster)
      statistics_data[:monthly] = get_monthly_statistics(tipster)
      statistics_data[:sports] = get_sports_statistics(tipster)
      statistics_data[:countries_competitions] = get_countries_competitions_statistics(tipster)
      statistics_data[:odds] = get_odds_statistics(tipster)
      statistics_data[:type_of_bets] = get_type_of_bets_statistics(tipster)
      ts
    end

    # Calculate previous week and last-n-months
    def get_last_n_months_statistics(tipster)
      tips = tipster.finished_tips
      last_n_month_statistics = {}
      monthly_statistics = {}
      sports_statistics = {}

      # Prepare date ranges for last_n_months
      (RANKING_RANGES + EXTRA_RANKING_RANGES).each do |range_key|
        date_range = date_range_parser(range_key)
        last_n_month_statistics[range_key] = BaseStatistics.new(date_range)
      end

      # Prepare date ranges for monthly statistics
      DateUtils.first_days_of_months_so_far_from(tipster.created_at.to_date).each do |date|
        date_range_of_month = DateUtils.date_range_of_month_for(date)
        monthly_statistics[DateUtils.name_of_month_for(date)] = BaseStatistics.new(date_range_of_month)
      end

      # Prepare for sports statistics
      sports = tipster.sports

      sports.each do |sport|
        sports_statistics[sport.name.downcase.parameterize('_')] = nil
      end

      sports_statistics = {}
      # Group published date and sort increase
      date_with_tips = tips.group_by(&:published_date)

      date_with_tips = date_with_tips.sort_by { |published_date, tips| published_date.to_time.to_i }
      # Loop per dates, ordered by increase
      date_with_tips.each do |published_date, tips|
        profit_of_current_date = 0
        total_amount_of_current_date = 0
        total_odds_of_current_date = 0
        number_correct_tips_current_date = 0
        number_tips_of_current_date = tips.size

        # Loop tips in date
        tips.each do |tip|
          total_amount_of_current_date += tip.amount
          total_odds_of_current_date += tip.odds
          # Money Money Money
          money_of_tip = if tip.correct?
                           number_correct_tips_current_date += 1
                           (tip.amount*(tip.odds - 1)).round(0)
                         else
                           -tip.amount
                         end
          profit_of_current_date += money_of_tip
        end

        # Update statistics_obj
        last_n_month_statistics.each do |range_key, statistics_obj|
          if statistics_obj.range.cover?(published_date)
            last_n_month_statistics[range_key].number_of_tips += number_tips_of_current_date
            last_n_month_statistics[range_key].total_odds += total_odds_of_current_date
            last_n_month_statistics[range_key].number_correct_tips += number_correct_tips_current_date
            last_n_month_statistics[range_key].total_amount += total_amount_of_current_date
            last_n_month_statistics[range_key].profit += profit_of_current_date
            last_n_month_statistics[range_key].profit_per_dates << {
                date: published_date,
                profit: last_n_month_statistics[range_key].profit
            }
          end
        end

        monthly_statistics.each do |range_key, statistics_obj|
          if statistics_obj.range.cover?(published_date)
            monthly_statistics[range_key].number_of_tips += number_tips_of_current_date
            monthly_statistics[range_key].total_odds += total_odds_of_current_date
            monthly_statistics[range_key].number_correct_tips += number_correct_tips_current_date
            monthly_statistics[range_key].total_amount += total_amount_of_current_date
            monthly_statistics[range_key].profit += profit_of_current_date

            # The above data is maybe use in future
            #monthly_statistics[range_key].profit_per_dates << {
            #    profit: monthly_statistics[range_key].profit
            #}
          end
        end
      end

      last_n_month_statistics.each do |key, val|
        last_n_month_statistics[key] = last_n_month_statistics[key].composite.format_for_store
      end

      monthly_statistics.each do |key, val|
        monthly_statistics[key] = monthly_statistics[key].composite.format_for_store
      end
      {
          last_n_months: last_n_month_statistics,
          monthly: monthly_statistics
      }
    end

    def get_monthly_statistics(tipster)

    end

    def get_sports_statistics(tipster)
    end

    # United Kingdom	+5388	  6%	  1022	  29%	  3.79
    def get_countries_competitions_statistics(tipster)
    end

    # (3.00 - 6.00)	 +5806	  8%	  910	  28%	  3.84
    def get_odds_statistics(tipsters)
    end

    # Winner  +7364   8%   1142    29%    3.77
    def get_type_of_bets_statistics(tiptser)
    end
  end

  SAMPLE = {
      tipster_id: 1,
      data: {
          'last_n_months' => {
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
          'sports' => {
              '<sport_name>' => {
                  'sport_id' => 'football',
                  'percentage' => '10',
                  #'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
              }
          },

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