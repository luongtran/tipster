# coding: utf-8
# Sample of a record
#{
#    tipster_id: 1,
#    data: {
#        'last_n_months' => {
#            'previous_week' => {
#                'from' => '2013-03-17', # The monday
#                'to' => '2013-03-23', # The Sunday
#                'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
#            },
#            'last_month' => {
#                'from' => '2013-02-23',
#                'to' => '2013-03-23',
#                'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
#                'profit_per_dates' => [
#                    'date' => '2013-03-15',
#                    'profit' => '457'
#                ]
#            },
#            #'last-month',
#            #'last-3-months',
#            #'last-6-months',
#            #'last-12-months',
#        },
#        'monthly' => [
#            {
#                'name' => 'Jan 2014',
#                 #'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
#            },
#            # ....
#        ],
#        'sports' => [
#            {
#                'sport_name' => 'Football',
#                'sport_code' => 'football',
#                'percentage' => '10',
#                #'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
#            },
#            # ....
#        ],
#        'countries_competitions' => [
#            {
#                'country_code' => 'EN',
#                'percentage' => '10'
#            }
#        ],
#        'type_of_bets' => [
#            {
#                'sport_name' => 'football',
#                'bet_type_name' => 'Match odds'
#                #'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
#            },
#            # ....
#        ],
#        'odds' => [
#            {
#                'range' => '3.0 - 6.0',
#                #'Profit	Yield	N° of Tips	Win rate	Avg. Odds'
#            },
#            # ....
#        ],
#        'profitable_months' => 3,
#        'total_months' => 8,
#        'avg_yield' => 25,
#        'avg_profit' => 234
#    }, # End of data
#    'update_at' => DateTime.now
#}

class TipsterStatistics < ActiveRecord::Base
  belongs_to :tipster
  validates_presence_of :tipster_id

  attr_accessor :parsed_data
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
          number_of_tips: @number_of_tips
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

  # ================= For saving a last n months statistics object
  class LastNMonthStatistics < BaseStatistics
    attr_accessor :profit_per_dates, :range, :from, :to, :total_yield, :avg_yield, :avg_profit

    def initialize(range)
      @range = range
      @profit_per_dates = []
      @statistics_number = StatisticsNumber.new
      @total_yield = 0
      @avg_yield = 0
      @avg_profit = 0
      self
    end

    def finish
      @avg_profit = (@statistics_number.profit/ @statistics_number.number_of_tips.to_f).round(1)
      @avg_yield = (@total_yield/ @statistics_number.number_of_tips.to_f).round(1)
      super
      self
    end

    def format_for_store
      {
          from: @range.first,
          to: @range.last,
          profit_per_dates: @profit_per_dates,
          avg_profit: @avg_profit,
          avg_yield: @avg_yield,
      }.merge(@statistics_number.format_for_store)
    end
  end

  # ================= For saving a monthly statistics object
  class MonthlyStatistics < BaseStatistics
    attr_accessor :month_name, :range

    def initialize(first_day)
      @range = DateUtil.date_range_of_month_for(first_day)
      @month_name = DateUtil.name_of_month_for(first_day)
      @profit_per_dates = []
      @statistics_number = StatisticsNumber.new
      self
    end

    def format_for_store
      {name: @month_name}.merge(@statistics_number.format_for_store)
    end
  end

  # ================= For saving a sport statistics object
  class SportStatistics < BaseStatistics
    attr_accessor :percentage, :sport_name, :sport_id, :sport_code, :number_of_tips, :total_tips

    def initialize(sport, total_tips)
      @sport_name = sport.name
      @sport_code = sport.code
      @sport_id = sport.id
      @total_tips = total_tips
      @number_of_tips, @percentage = 0, 0
      @statistics_number = StatisticsNumber.new
      self
    end

    def format_for_store
      {
          sport_name: @sport_name,
          sport_code: @sport_code,
          percentage: @percentage
      }.merge(@statistics_number.format_for_store)
    end

    def finish
      @percentage = (@statistics_number.number_of_tips * 100/@total_tips.to_f).round(0) unless @total_tips.zero?
      super
      self
    end
  end

  # ================= For saving a bet type statistics object
  class BetTypeStatistics < BaseStatistics
    attr_accessor :percentage, :bet_type_name, :sport_name, :bet_type_id, :total_tips

    def initialize(bet_type, total_tips)
      @bet_type_name = bet_type.name
      @bet_type_id = bet_type.id
      @total_tips = total_tips
      @sport_name = bet_type.sport.name
      @percentage = 0
      @statistics_number = StatisticsNumber.new
      self
    end

    def finish
      @percentage = (@statistics_number.number_of_tips * 100/@total_tips.to_f).round(0) unless @total_tips.zero?
      super
      self
    end

    def format_for_store
      {
          bet_type_name: @bet_type_name,
          sport_name: @sport_name,
          percentage: @percentage
      }.merge(@statistics_number.format_for_store)
    end

    def to_chart

    end
  end

  # ================= For saving a country/compoetition statistics object
  class CountryCompetitionStatistics < BaseStatistics
    attr_accessor :percentage
  end

  # ================= For saving a odds statistics object
  class OddStatistics < BaseStatistics
    attr_accessor :percentage, :range, :range_name, :total_tips

    def initialize(float_range, total_tips)
      @range = float_range
      @range_name = if float_range.last.infinite? == 1 # range end with +infinity
                      "#{I18n.t('common.over')} #{float_range.first}"
                    elsif float_range.first.infinite? == -1 # range start with -infinity
                      "#{I18n.t('common.under')} #{float_range.last}"
                    else
                      float_range.to_s.split('..').join(' - ')
                    end
      @percentage = 0
      @total_tips = total_tips
      @statistics_number = StatisticsNumber.new
    end

    def finish
      unless @total_tips.zero?
        @percentage = (@statistics_number.number_of_tips * 100/@total_tips.to_f).round(0)
      end
      super
      self
    end

    def format_for_store
      {
          range_name: @range_name,
          percentage: @percentage,
      }.merge(@statistics_number.format_for_store)
    end
  end

  UPDATE_PERIOD = 2.hours

  RANKING_RANGES = [
      OVERALL = 'overall',
      LAST_12_MONTHS = 'last_12_months',
      LAST_6_MONTHS = 'last_6_months',
      LAST_3_MONTHS = 'last_3_months',
      LAST_MONTH = 'last_month'
  ]
  # Extra ranking range
  EXTRA_RANKING_RANGES = [
      PREVIOUS_WEEK = 'previous_week'
  ]

  DEFAULT_RANKING_RANGE = LAST_3_MONTHS

  ODDS_RANGES = [
      -Float::INFINITY..1.4,
      1.50..1.75,
      1.76..2.1,
      2.10..3.0,
      3.0..Float::INFINITY
  ]
  class << self
    def date_range_parser(range_in_string)
      end_date = Date.today
      start_date =
          case range_in_string
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
      start_date.beginning_of_day..end_date.end_of_day
    end

    def make_statistics_for(tipster)
      loger = Logger.new "log/upda_tipster_statistics.log"
      tips = tipster.finished_tips
      total_tips = tips.size

      tipster_statistics = tipster.statistics
      if tipster_statistics.nil?
        tipster_statistics = new(tipster_id: tipster.id)
      end

      # ==============  Prepare for last_n_months and previous week statistics
      last_n_month_statistics = {}
      (RANKING_RANGES + EXTRA_RANKING_RANGES).each do |range_key|
        date_range = date_range_parser(range_key)
        last_n_month_statistics[range_key] = LastNMonthStatistics.new(date_range)
      end

      # ==============  Prepare date ranges for monthly statistics
      monthly_statistics = []
      DateUtil.first_days_of_months_so_far_from(tipster.created_at.to_date).each do |date|
        monthly_statistics << MonthlyStatistics.new(date)
      end

      # ==============  Prepare for sports statistics
      tipster_sports = tipster.sports
      sports_statistics = []
      tipster_sports.each do |sport|
        sports_statistics << SportStatistics.new(sport, total_tips)
      end

      # ============== Prepare for types of bet statistics
      bet_types_statistics = []
      tipster_sports.each do |sport|
        sport.bet_types.each do |bet_type|
          bet_types_statistics << BetTypeStatistics.new(bet_type, total_tips)
        end
      end

      # ============== Prepare for odds statistics
      odds_statistics = []
      ODDS_RANGES.each do |float_range|
        odds_statistics << OddStatistics.new(float_range, total_tips)
      end

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

        total_yield_of_current_date = 0
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
          total_yield_of_current_date += (money_of_tip*100)/(tip.amount)

          # === Saving for sport
          sports_statistics.each do |statistics_obj|
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

          # === Saving for bet types statistics
          bet_types_statistics.each do |statistics_obj|
            if tip.bet_type_id == statistics_obj.bet_type_id
              # TODO: DRYing up !
              statistics_obj.statistics_number.number_of_tips += 1
              statistics_obj.statistics_number.total_odds += tip.odds
              statistics_obj.statistics_number.number_correct_tips += 1 if tip.correct?
              statistics_obj.statistics_number.total_amount += tip.amount
              statistics_obj.statistics_number.profit += money_of_tip
              break
            end
          end

          # === Saving for odds statistics
          odds_statistics.each do |statistics_obj|
            if statistics_obj.range.include? tip.odds
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

        # === Saving for last n months and previous week statistics
        last_n_month_statistics.each do |range_key, statistics_obj|
          if statistics_obj.range.cover?(published_date)
            # TODO: DRYing up !
            last_n_month_statistics[range_key].statistics_number.number_of_tips += number_tips_of_current_date
            last_n_month_statistics[range_key].statistics_number.total_odds += total_odds_of_current_date
            last_n_month_statistics[range_key].statistics_number.number_correct_tips += number_correct_tips_current_date
            last_n_month_statistics[range_key].statistics_number.total_amount += total_amount_of_current_date
            last_n_month_statistics[range_key].statistics_number.profit += profit_of_current_date
            last_n_month_statistics[range_key].total_yield += total_yield_of_current_date
            last_n_month_statistics[range_key].profit_per_dates << {
                date: published_date,
                profit: last_n_month_statistics[range_key].statistics_number.profit
            }
          end
        end

        # === Saving for monthy statistics
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
        x_bet_types_statistics << statistics_obj.finish.format_for_store
      end

      x_odds_statistics = []
      odds_statistics.each do |statistics_obj|
        x_odds_statistics << statistics_obj.finish.format_for_store
      end

      # Get profitable months/all months
      total_months = x_monthly_statistics.size
      profitable_months = 0
      x_monthly_statistics.each do |month|
        if month[:profit] > 0
          profitable_months += 1
        end
      end
      # Got all statistics
      statistics_data =
          {
              last_n_months: last_n_month_statistics,
              monthly: x_monthly_statistics,
              sports: x_sports_statistics,
              bet_types: x_bet_types_statistics,
              odds: x_odds_statistics,
              profitable_months: profitable_months,
              total_months: total_months
          }

      # === Now we will prepate for saving the statistics data as json string
      tipster_statistics[:data] = statistics_data.to_json
      tipster_statistics.save
      tipster_statistics
    end
  end

  # ==================================================================================
  # INSTANCE METHODS
  # ==================================================================================

  # Convert statistics data from a json_string to a Hash
  def parsed_data
    @parsed_data ||= JSON.parse(self.data).deep_symbolize_keys
    @parsed_data
  end

  def get_bet_types_chart
    bet_types_statistic = parsed_data[:bet_types]

    sanitized_bet_types_statistic = []
    bet_types_statistic.each do |bet_type|
      if bet_type['percentage'].to_i > 0
        sanitized_bet_types_statistic << {
            name: bet_type['bet_type_name'][0..12],
            y: bet_type['percentage']
        }
      end
    end
    LazyHighCharts::HighChart.new('graph') do |f|
      f.series(
          :data => sanitized_bet_types_statistic,
      )
      f.plotOptions(
          pie: {
              allowPointSelect: true,
              cursor: 'pointer',
              dataLabels: {
                  enabled: true
              }
          }
      )
      f.tooltip(
          pointFormat: '<b>{point.percentage}%</b>',
          percentageDecimals: 1
      )
      f.chart(
          :type => 'pie',
          width: 300,
          height: 300
      )
    end
  end

  def get_sports_chart
    sports_statistics = parsed_data[:sports]
    sanitized_sports_statistic = []
    sports_statistics.each do |bet_type|
      if bet_type['percentage'].to_i > 0
        sanitized_sports_statistic << {
            name: bet_type['sport_name'],
            y: bet_type['percentage']
        }
      end
    end
    LazyHighCharts::HighChart.new('graph') do |f|
      f.series(
          :data => sanitized_sports_statistic,
      )
      f.plotOptions(
          pie: {
              allowPointSelect: true,
              cursor: 'pointer',
              dataLabels: {
                  enabled: true
              }
          }
      )
      f.tooltip(
          pointFormat: '<b>{point.percentage}%</b>',
          percentageDecimals: 1
      )
      f.chart(
          :type => "pie",
          width: 200,
          height: 200
      )
    end
  end

  def get_odds_chart
    odds_statistics = parsed_data[:odds]
    sanitized_odds_statistic = []
    odds_statistics.each do |bet_type|
      if bet_type['percentage'].to_i > 0
        sanitized_odds_statistic << {
            name: bet_type['range_name'],
            y: bet_type['percentage']
        }
      end
    end
    LazyHighCharts::HighChart.new('graph') do |f|
      f.series(
          :data => sanitized_odds_statistic,
      )
      f.plotOptions(
          pie: {
              allowPointSelect: true,
              cursor: 'pointer',
              dataLabels: {
                  enabled: true
              }
          }
      )
      f.tooltip(
          pointFormat: '<b>{point.percentage}%</b>',
          percentageDecimals: 1
      )
      f.chart(
          :type => "pie",
          width: 300,
          height: 300
      )
    end
  end

  def get_profit_chart(range)
    statistics_in_range = self.parsed_data[:last_n_months][range]
    dates_for_chart = statistics_in_range[:profit_per_dates].map { |ppd| ppd['date'].to_date.strftime("%b %d") }
    values_for_chart = statistics_in_range[:profit_per_dates].map { |ppd| ppd['profit'] }
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(
          :text => nil
      )
      f.xAxis(
          :categories => dates_for_chart,
          tickInterval: 5
      )
      f.series(
          :name => 'Profit',
          :yAxis => 0,
          :color => '#4D759E',
          :data => values_for_chart,
          showInLegend: false
      )
      f.yAxis [
                  :title => {
                      :text => "Profit in Euro",
                      :margin => 20
                  }
              ]
      f.chart(
          :defaultSeriesType => "line",
          height: 350
      )
    end
  end
end