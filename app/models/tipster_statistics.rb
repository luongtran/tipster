class TipsterStatistics < ActiveRecord::Base
  belongs_to :tipster
  validates_presence_of :tipster

  class StatisticsNumber
    attr_accessor :profit, :number_correct_tips,
                  :total_amount, :total_odds, :number_of_tips,
                  :yield, :hit_rate, :avg_odds

    def initialize
      @profit = 0
      @total_odds = 0
      @number_of_tips = 0
      @number_correct_tips = 0
      @total_amount = 0
      @yield = 0
      @hit_rate = 0
      @avg_odds = 0
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
          profit: @profit,
          yield: @yield,
          hit_rate: @hit_rate,
          avg_odds: @avg_odds,
      }
    end
  end

  class BaseStatistics
    # :statistics_number is a instance of StatisticsNumber
    attr_accessor :statistics_number

    def finish
      @statistics_number.composite
      self
    end
  end

  class LastNMonthStatistics < BaseStatistics
    attr_accessor :profit_per_dates, :range, :from, :to

    def initialize(range)
      @range = range
      @profit_per_dates = []
      @statistics_number = StatisticsNumber.new
      self
    end

    def format_for_store
      {from: @range.first, to: @range.last}.merge(@statistics_number.format_for_store)
    end
  end

  class MonthlyStatistics < BaseStatistics
    attr_accessor :month_name, :range

    def initialize(first_day)
      @range = DateUtils.date_range_of_month_for(first_day)
      @month_name = DateUtils.name_of_month_for(first_day)
      @profit_per_dates = []
      @statistics_number = StatisticsNumber.new
      self
    end

    def format_for_store
      {name: @month_name}.merge(@statistics_number.format_for_store)
    end
  end

  class SportStatistics < BaseStatistics
    attr_accessor :percentage, :sport_name, :sport_id, :number_of_tips, :total_tips

    def initialize(sport, total_tips)
      @sport_name = sport.name
      @total_tips = total_tips
      # TODO: think to use 'code' of instead for 'id' of sport
      @sport_id = sport.id
      @number_of_tips, @percentage = 0, 0
      @statistics_number = StatisticsNumber.new
      self
    end

    def format_for_store
      {name: @sport_name, percentage: @percentage}.merge(@statistics_number.format_for_store)
    end

    def finish
      @percentage = (@statistics_number.number_of_tips * 100/@total_tips.to_f).round(0) unless @total_tips.zero?
      super
      self
    end
  end

  class BetTypeStatistics < BaseStatistics
    attr_accessor :percentage, :bet_type_name, :sport_name, :bet_type_id

    def initialize(bet_type)
      @bet_type_name = bet_type.name
      @bet_type_id = bet_type.id
      @sport_name = bet_type.sport.name
      @percentage = 0
      @statistics_number = StatisticsNumber.new
      self
    end

    def format_for_store
      {name: @bet_type_name, percentage: @percentage}.merge(@statistics_number.format_for_store)
    end
  end

  class CountryCompetitionStatistics < BaseStatistics
    attr_accessor :percentage
  end
  class OddStatistics < BaseStatistics
    attr_accessor :percentage
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

      ts
    end

    # Calculate previous week and last-n-months
    def get_last_n_months_statistics(tipster)
      logger = Logger.new "log/statis.log"
      tips = tipster.finished_tips
      last_n_month_statistics = {}
      monthly_statistics = []
      sports_statistics = {}

      # ==============  Prepare for last_n_months statistics
      (RANKING_RANGES + EXTRA_RANKING_RANGES).each do |range_key|
        date_range = date_range_parser(range_key)
        last_n_month_statistics[range_key] = LastNMonthStatistics.new(date_range)
      end

      # ==============  Prepare date ranges for monthly statistics

      DateUtils.first_days_of_months_so_far_from(tipster.created_at.to_date).each do |date|
        monthly_statistics << MonthlyStatistics.new(date)
      end

      # ==============  Prepare for sports statistics
      tipster_sports = tipster.sports.includes(:bet_types)
      sports_statistics = []
      tipster_sports.each do |sport|
        sports_statistics << SportStatistics.new(sport, tips.size)
      end

      # ============== Prepare for types of bet statistics
      bet_types_statistics = []
      logger.info "\n Size Before: #{bet_types_statistics.size}"
      logger.info bet_types_statistics
      tipster_sports.each do |sport|
        sport.bet_types.each do |bet_type|
          bet_types_statistics << BetTypeStatistics.new(bet_type)
        end
      end

      logger.info "\n Size After: #{bet_types_statistics.size}"
      logger.info bet_types_statistics
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

          # Saving for sport
          sports_statistics.map! do |statistics_obj|
            if tip.sport_id == statistics_obj.sport_id
              # TODO: DRYing up !
              statistics_obj.statistics_number.number_of_tips += 1
              statistics_obj.statistics_number.total_odds += tip.odds
              statistics_obj.statistics_number.number_correct_tips += 1 if tip.correct?
              statistics_obj.statistics_number.total_amount += tip.amount
              statistics_obj.statistics_number.profit += money_of_tip
              break
            end
          end

          # Saving for bet types
          bet_types_statistics.map! do |statistics_obj|
            if statistics_obj && (tip.bet_type_id == statistics_obj.bet_type_id)
              # TODO: DRYing up !
              statistics_obj.statistics_number.number_of_tips += 1
              statistics_obj.statistics_number.total_odds += tip.odds
              statistics_obj.statistics_number.number_correct_tips += 1 if tip.correct?
              statistics_obj.statistics_number.total_amount += tip.amount
              statistics_obj.statistics_number.profit += money_of_tip
              break
            end
          end
        end

        # Update statistics_obj
        last_n_month_statistics.each do |range_key, statistics_obj|
          if statistics_obj.range.cover?(published_date)
            # TODO: DRYing up !
            last_n_month_statistics[range_key].statistics_number.number_of_tips += number_tips_of_current_date
            last_n_month_statistics[range_key].statistics_number.total_odds += total_odds_of_current_date
            last_n_month_statistics[range_key].statistics_number.number_correct_tips += number_correct_tips_current_date
            last_n_month_statistics[range_key].statistics_number.total_amount += total_amount_of_current_date
            last_n_month_statistics[range_key].statistics_number.profit += profit_of_current_date
            last_n_month_statistics[range_key].profit_per_dates << {
                date: published_date,
                profit: last_n_month_statistics[range_key].statistics_number.profit
            }
          end
        end

        monthly_statistics.each do |statistics_obj|
          if statistics_obj.range.cover?(published_date)
            # TODO: DRYing up !
            statistics_obj.statistics_number.number_of_tips += number_tips_of_current_date
            statistics_obj.statistics_number.total_odds += total_odds_of_current_date
            statistics_obj.statistics_number.number_correct_tips += number_correct_tips_current_date
            statistics_obj.statistics_number.total_amount += total_amount_of_current_date
            statistics_obj.statistics_number.profit += profit_of_current_date
          end
        end
      end

      last_n_month_statistics.each do |key, val|
        last_n_month_statistics[key] = last_n_month_statistics[key].finish.format_for_store
      end

      x_monthly_statistics = []
      monthly_statistics.each do |statistics_obj|
        x_monthly_statistics << statistics_obj.finish.format_for_store
      end

      x_sports_statistics = []
      sports_statistics.each do |statistics_obj|
        x_sports_statistics << statistics_obj.finish.format_for_store
      end

      x_bet_types_statistics = []
      bet_types_statistics.each do |statistics_obj|
        x_bet_types_statistics << statistics_obj.finish.format_for_store unless statistics_obj.nil?
      end
      {
          last_n_months: last_n_month_statistics,
          monthly: x_monthly_statistics,
          sports: x_sports_statistics,
          bet_types: x_bet_types_statistics
      }
    end

    # United Kingdom	+5388	  6%	  1022	  29%	  3.79

    # (3.00 - 6.00)	 +5806	  8%	  910	  28%	  3.84

    # Winner  +7364   8%   1142    29%    3.77

  end

  SAMPLE = {
      tipster_id: 1,
      data: {
          'last_n_months' => {
              'previous_week' => {
                  'from' => 'from date',
                  'to' => 'to date',
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
                  'name' => 'football',
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