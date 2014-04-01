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

  # ==============================================================================
  # ATTRIBUTES
  # ==============================================================================
  PROFILE_ATTRS = [:display_name, :full_name]

  # This is list of attributes for saving the statistics data
  attr_accessor :number_of_tips, :hit_rate, :avg_odds, :profit, :yield, :avg_yield, :avg_profit,
                :profit_per_months, :profit_per_dates, :total_months,
                :tips_per_dates, :profitable_months, :current_statistics_range

  attr_accessor :monthly_statistics, :sports_statistics,
                :bet_types_statistics, :odds_statistics

  # LazyHighChart objects
  attr_accessor :monthly_chart, :sports_chart,
                :bet_types_chart, :odds_chart, :profit_chart

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================

  has_one :statistics, class_name: TipsterStatistics

  has_many :tips, as: :author do
    def recent(count = 10)
      proxy_association.owner.tips.includes(:sport, :match).order('created_at desc').limit(count)
    end
  end

  has_many :finished_tips, -> { where("tips.status = ? AND tips.free = ?", Tip::STATUS_FINISHED, false) }, class_name: Tip, as: :author do
    def in_range(range)
      # FIXME
      proxy_association.owner.tips.where(published_at: range).where("tips.status = ? AND tips.free = ?", Tip::STATUS_FINISHED, false)
    end
  end

  has_and_belongs_to_many :sports, -> { uniq }
  mount_uploader :avatar, AvatarUploader

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :display_name, uniqueness: {case_sensitive: false}
  validates_presence_of :display_name, :full_name
  # ==============================================================================
  # SCOPE
  # ==============================================================================
  scope :active, -> { where(active: true) }

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def load_data(params = {})
      relation = perform_filter_params(params)

      # paging_info = parse_paging_params(params)
      # Paginate with Kaminari
      # relation.includes([]).order(sort_string).page(paging_info.page).per(paging_info.page_size)

      tipsters = relation.includes(:statistics)

      # Load statistics data
      tipsters.each do |tipster|
        tipster.prepare_statistics_data(params)
      end

      sorting_info = parse_sort_params(params)
      if sorting_info.increase?
        tipsters.sort_by! { |tipster| tipster.send("#{sorting_info.sort_by}") }
      else
        tipsters.sort_by! { |tipster| -tipster.send("#{sorting_info.sort_by}") }
      end
      tipsters
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

    def sanitized_ranking_range_param(params)
      ranking_range =
          if params[:ranking].present?
            params[:ranking]
          else
            TipsterStatistics::DEFAULT_RANKING_RANGE
          end
      ranking_range.gsub('-', '_')
    end

    # Return LazayHightChart object for draw profile chart
    def profit_chart_for_tipster(range)

      LazyHighCharts::HighChart.new('graph') do |f|
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
    end

    def find_tipsters_of_week(count = 3)
      tipsters = load_data(ranking: TipsterStatistics::PREVIOUS_WEEK)
      tipsters.sort_by { |tipster| -tipster.profit }.first(count)
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

  #def load_chart(type)
  #  case type
  #    when 'profit' # Use in tipsters index page
  #      @profit_chart = self.statistics.get_bet_types_chart.get_profit_chart
  #    when 'all'
  #      @profit_chart = self.statistics.get_bet_types_chart.get_profit_chart
  #      @bet_types_chart = self.statistics.get_bet_types_chart
  #      @odds_chart = self.statistics.get_odds_chart
  #      @sports_chart = self.statistics.get_sports_chart
  #  end
  #  self
  #end

  def prepare_statistics_data(params, details = false)
    ranking_range ||= self.class.sanitized_ranking_range_param(params).to_sym

    # Parse and get statistics data depending to ranking param
    statistics_data = self.statistics.parsed_data
    last_n_months_statistics = statistics_data[:last_n_months][ranking_range]

    # Assign statistic attr_accessors for each tipster object
    @profitable_months = statistics_data[:profitable_months]
    @total_months = statistics_data[:total_months]

    @profit = last_n_months_statistics[:profit]
    @yield = last_n_months_statistics[:yield]
    @avg_odds = last_n_months_statistics[:avg_odds]
    @number_of_tips = last_n_months_statistics[:number_of_tips]
    @hit_rate = last_n_months_statistics[:hit_rate]

    @avg_yield = last_n_months_statistics[:avg_yield]
    @avg_profit = last_n_months_statistics[:avg_profit]

    @current_statistics_range = ranking_range # Saving for display or you know what the current range
    @profit_per_dates = last_n_months_statistics[:profit_per_dates]

    # Load all statistics
    if details
      @monthly_statistics = statistics_data[:monthly].map { |statistic| statistic.symbolize_keys }
      @sports_statistics = statistics_data[:sports].map { |statistic| statistic.symbolize_keys }
      @bet_types_statistics = statistics_data[:bet_types].map { |statistic| statistic.symbolize_keys }
      @odds_statistics = statistics_data[:odds].map { |statistic| statistic.symbolize_keys }
    end


    # Prepare charts
    @profit_chart = self.statistics.get_profit_chart(ranking_range)
    @bet_types_chart = self.statistics.get_bet_types_chart
    @odds_chart = self.statistics.get_odds_chart
    @sports_chart = self.statistics.get_sports_chart

    self
  end

  def profit_values_for_chart
    @profit_per_dates.map { |ppd| ppd['profit'] }
  end

  def profit_dates_for_chart
    @profit_per_dates.map { |ppd| ppd['date'].to_date.strftime("%b %d") }
  end

  # Return lastest tips limit by the given quantity
  def recent_tips(quantity = 10)
    self.tips.includes([:author, :sport]).order('created_at desc').limit(quantity)
  end

  # Get all first date of the months from join date to today
  # Example return: ['2013-02-01','2013-02-01' ...]
  def first_dates_of_months_since_join
    DateUtil.first_days_of_months_so_far_from(self.created_at.to_date)
  end

  def update_description(text)
    self.update_column :description, text
  end
end
