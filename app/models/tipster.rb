# == Schema Information
#
# Table name: tipsters
#
#  id           :integer          not null, primary key
#  display_name :string(255)
#  full_name    :string(255)
#  avatar       :string(255)
#  status       :integer
#  active       :boolean          default(TRUE)
#  description  :text
#  created_at   :datetime
#  updated_at   :datetime
#

class Tipster < ActiveRecord::Base
  include Accountable

  DEFAULT_PAGE_SIZE = 20
  DEFAULT_SORT_FIELD = 'profit'

  RANKING_SORT_BY = [
      BY_PROFIT = 'profit',
      BY_YIELD = 'yield',
  ]
  DEFAULT_RANKING_SORT_BY = BY_PROFIT

  RANKING_RANGES = [
      OVERALL = 'overall',
      LAST_12_MONTHS = 'last-12-months',
      LAST_6_MONTHS = 'last-6-months',
      LAST_3_MONTHS = 'last-3-months',
      LAST_MONTH = 'last-month'
  ]

  DEFAULT_RANKING_RANGE = LAST_3_MONTHS

  # ==============================================================================
  # ATTRIBUTES
  # ==============================================================================
  PROFILE_ATTRS = [:display_name, :full_name]

  # This is list of attributes for saving the statistics data
  attr_accessor :number_of_tips, :hit_rate, :avg_odds, :profit, :yield,
                :profit_per_months, :profit_per_dates, :current_statistics_range,
                :tips_per_dates, :profitable_months,
                :profit_on_previous_week, :total_amount_on_previous_week

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================

  has_many :tips, as: :author do
    def recent(count = 10)
      proxy_association.owner.tips.includes(:sport).order('created_at desc').limit(count)
    end
  end

  has_many :finished_tips, -> { where("tips.status = ? AND tips.free = ?", Tip::STATUS_FINISHED, false) }, class_name: Tip, as: :author do
    def in_range(range)
      proxy_association.owner.tips.where(published_at: range)
    end
  end

  has_and_belongs_to_many :sports, -> { uniq }
  mount_uploader :avatar, AvatarUploader

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :display_name, uniqueness: {case_sensitive: false}

  # ==============================================================================
  # SCOPE
  # ==============================================================================
  scope :active, -> { where(active: true) }

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    attr_accessor :top_of_previous_week

    def load_data(params = {})
      relation = perform_filter_params(params)
      sorting_info = parse_sort_params(params)
      # paging_info = parse_paging_params(params)
      # Paginate with Kaminari
      #relation.includes([])
      #.order(sort_string)
      #.page(paging_info.page)
      #.per(paging_info.page_size)

      ranking_range = parse_range_param(params)
      range = range_paser(ranking_range)

      result = relation.includes(:finished_tips)
      .where("tips.published_at" => range).references(:tips)

      result.each do |tipster|
        tipster.get_statistics(params)
      end

      @top_of_previous_week = result.sort_by { |tipster| -tipster.profit_on_previous_week }.first(5)

      if sorting_info.increase?
        result.sort_by { |tipster| tipster.send("#{sorting_info.sort_by}") }
      else
        result.sort_by { |tipster| -tipster.send("#{sorting_info.sort_by}") }
      end

    end

    def perform_filter_params(params, relation = self)
      unless params[:sport].blank?
        relation = relation.perform_sport_param(params[:sport])
      end
      unless params[:status].blank?
        relation = relation.perform_status_param(params[:status])
      end
      relation
    end

    def perform_sport_param(sport, relation = self)
      sport = Sport.find_by(code: sport)
      relation = relation.where(id: sport.tipster_ids) if sport
      relation
    end

    def perform_status_param(active, relation = self)
      return relation if active.blank?
      active = (active == 'active') ? true : false
      relation = relation.where(:active => active)
      relation
    end

    def parse_range_param(params)
      if params[:ranking].present?
        params[:ranking]
      else
        DEFAULT_RANKING_RANGE
      end
    end

    def find_top_of_previous_week(limit = 3)
      @top_of_previous_week.first(limit)
    end

    # Return the start & end date specify by given range string
    def range_paser(range)
      end_date = Date.today
      start_date = case range
                     when LAST_MONTH
                       30.days.ago
                     when LAST_3_MONTHS
                       90.days.ago
                     when LAST_6_MONTHS
                       180.days.ago
                     when LAST_12_MONTHS
                       365.days.ago
                     when OVERALL
                       self.order("created_at asc").first.created_at.to_date
                     else
                       90.days.ago
                   end
      start_date..end_date
    end

    # Return LazayHightChart object for draw profile chart
    def profit_chart_for_tipster(tipster)
      chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(
            :text => nil
        )
        f.xAxis(
            :categories => tipster.profit_dates_for_chart,
            tickInterval: 5
        )
        f.series(
            :name => 'Profit',
            :yAxis => 0,
            :color => '#AABF46',
            :data => tipster.profit_values_for_chart,
            showInLegend: false
        )
        f.yAxis [
                    :title => {
                        :text => "Profit in Euro",
                        :margin => 20
                    }
                ]
        f.chart({:defaultSeriesType => "line"})
      end
      chart
    end

    # ==============================================================================
    # PROTECTED CLASS METHODS
    # ==============================================================================
    protected

    # Return SortingInfo object contains:
    #  sort_by: the name of column or field
    #  direction: asc | desc
    def parse_sort_params(params)
      SortingInfo.new(
          params[:sort_by],
          default_sort_by: DEFAULT_RANKING_SORT_BY,
          default_sort_direction: SortingInfo::DECREASE
      )
    end

    # Return PagingInfo object contains:
    #  page: the page number requested, default = 1
    #  per_page: the number of results per page
    def parse_paging_params(params)
      p_id = params[:page].presence
      p_id ||= 1
      p_size = params[:page_size].presence
      p_size ||= DEFAULT_PAGE_SIZE
      PagingInfo.new(
          :page => p_id,
          :page_size => p_size
      )
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def to_param
    "#{self.id}-#{self.display_name}".parameterize
  end

  def first_name
    self.full_name.split(' ').first.capitalize
  end

  def last_name
    self.full_name.split(' ').try(:second).try(:capitalize)
  end

  def followers
    subscriptions_tipsters = SubscriptionTipster.where(tipster_id: self.id)
    subscriptions = subscriptions_tipsters.map { |s_t| s_t.subscription } unless subscriptions_tipsters.empty?
    subscribers = []
    unless subscriptions.nil? || subscriptions.empty?
      subscriber_ids = subscriptions.map { |subscription| subscription.subscriber }
    end
    subscribers
  end

  # Substract tipster's bankroll after published a tip
  def subtract_bankroll(amount)
  end

  # Calculate statistics for ranking
  def get_statistics(params = {})
    tips = nil

    # The finished tips already loaded when query from multiple tipsters
    if self.finished_tips.loaded?
      tips = self.finished_tips
    else
      ranking_range = self.class.parse_range_param(params)
      @current_statistics_range = ranking_range
      tips = self.finished_tips.in_range(self.class.range_paser(ranking_range))
    end

    prev_week_range = DateUtils.previous_week_date_range

    # Save the number of tip
    @number_of_tips = tips.length

    @profit_per_dates = [] # save profit after each date
    @profit_on_previous_week = 0 # save profit on previous week to find "top n of the week"
    @total_amount_on_previous_week = 0
    @tips_per_dates = [] # tips counter per every date
    @yield = 0 # incremental
    @profit = 0 # incremental
    correct_tips = 0 # incremental
    total_odds = 0 # incremental
    total_amount = 0 # incremental

    # Grouping by published date
    # FIXME: it's should be finished date
    date_with_tips = tips.group_by(&:published_date)

    date_with_tips.each do |date, tips|
      # Save number of tips on the date
      @tips_per_dates << {date: date, tips_count: tips.size}

      money_on_current_date = 0
      amount_on_current_date = 0
      tips.each do |tip|
        money_of_the_tip = 0
        total_odds += tip.odds
        total_amount += tip.amount
        if tip.correct?
          correct_tips += 1
          #profit_on_current_date +=
          money_of_the_tip = (tip.amount*(tip.odds - 1)).round(0)
        else
          money_of_the_tip = -tip.amount
        end
        @profit += money_of_the_tip
        money_on_current_date += money_of_the_tip
        amount_on_current_date += tip.amount
      end

      if prev_week_range.include? date
        @profit_on_previous_week += money_on_current_date
        @total_amount_on_previous_week += amount_on_current_date
      end

      @profit_per_dates << {date: date, profit: @profit}
    end

    #  Cal avg of odds and hit(win) rate
    if @number_of_tips.zero?
      @hit_rate, @avg_odds, @yield = 0, 0, 0
    else
      @hit_rate = (correct_tips*100/@number_of_tips.to_f).round(1)
      @avg_odds = (total_odds/@number_of_tips.to_f).round(1)
      @yield = (@profit*100/total_amount.to_f).round(0)
    end
    self
  end

  # Calculate statistic on per month
  # Month	    Profit	Yield	  N° of Tips
  # Oct 13	  +169	   27%	     9
  def get_monthly_statistics
    result = []
    first_dates_of_months_since_join.each do |date|
      current_range = date.beginning_of_month.beginning_of_day..date.end_of_month.end_of_day
      finished_tips_in_range = self.finished_tips.in_range(current_range)
      _profit = 0
      _yield = 0
      _correct_tips = 0
      _total_odds = 0
      _total_tips = finished_tips_in_range.size
      _total_amount = 0
      finished_tips_in_range.each do |tip|
        if tip.correct?
          _correct_tips += 1
          money_of_the_tip = (tip.amount*(tip.odds - 1)).round(0)
        else
          money_of_the_tip = -tip.amount
        end
        _profit += money_of_the_tip
        _total_odds += tip.odds
        _total_amount += tip.amount
      end

      if _total_tips.zero?
        result << {
            date: date,
            number_of_tips: 0,
            profit: 0,
            yield: 0,
            hit_rate: 0,
            avg_odds: 0
        }
      else
        result << {
            date: date,
            number_of_tips: finished_tips_in_range.count,
            profit: _profit,
            yield: (_profit*100/_total_amount.to_f).round(0),
            hit_rate: (_correct_tips*100/_total_tips.to_f).round(1),
            avg_odds: (_total_odds/_total_tips.to_f).round(1)
        }
      end
    end
    # Sort by date descrease
    result.map.sort_by { |monthly| -(monthly[:date].to_time.to_i) }
  end

  def profit_in_string(include_unit = false)
    sign = '+' if @profit > 0
    "#{sign}#@profit #{I18n.t('tipster.units') if include_unit}"
  end

  def yield_in_string
    "#@yield%"
  end

  def profit_values_for_chart
    @profit_per_dates.map { |ppd| ppd[:profit] }
  end

  def profit_dates_for_chart
    @profit_per_dates.map { |ppd| ppd[:date].strftime("%b %d") }
  end

  def hit_rate_in_string
    "#@hit_rate%"
  end

  # The ratio of the number of profitable months per overall months
  # Example return: 3/6
  def profitable_months
    "#{rand(3..6)}/#{first_dates_of_months_since_join.count}"
  end

  # Return lastest tips limit by the given quantity
  def recent_tips(quantity = 10)
    self.tips.includes([:author, :sport]).order('created_at desc').limit(quantity)
  end

  # Get all first date of the months from join date to today
  # Example return: ['2013-02-01','2013-02-01' ...]
  def first_dates_of_months_since_join
    dates = []
    first_date_of_first_month = self.created_at.to_date.beginning_of_month
    first_date_of_last_month = Date.today.beginning_of_month
    tmp_date = first_date_of_first_month
    while tmp_date <= first_date_of_last_month
      dates << tmp_date
      tmp_date = tmp_date.next_month
    end
    dates
  end

  def update_description(text)
    self.update_column :description, text
  end
end
