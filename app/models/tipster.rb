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
#  created_at   :datetime
#  updated_at   :datetime
#

class Tipster < ActiveRecord::Base
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

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessor :number_of_tips, :hit_rate, :avg_odds, :profit, :yield,
                :profit_per_months, :profit_per_dates, :current_statistics_range, :tips_per_dates,
                :profitable_months

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  has_one :account, as: :rolable
  has_many :tips, as: :author
  has_and_belongs_to_many :sports
  accepts_nested_attributes_for :account

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
  after_update :crop_avatar

  delegate :email, to: :account, prefix: false

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def load_data(params = {})
      relation = perform_filter_params(params)
      sorting_info = parse_sort_params(params)
      # paging_info = parse_paging_params(params)
      # Paginate with Kaminari
      #relation.includes([])
      #.order(sort_string)
      #.page(paging_info.page)
      #.per(paging_info.page_size)

      result = relation.includes([:account])
      result.each do |tipster|
        tipster.get_statistics(params)
      end
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
      sport = Sport.find_by(name: sport)
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

    # Find the top 3(profit) of the last week
    def find_top_3_last_week(params)
      # FIXME: this method isn't really implement yet
      relation = self
      unless params[:sport].blank?
        relation = relation.perform_sport_param(params[:sport])
      end
      relation.includes([:account]).limit(3)
    end

    # Return the start & end date specify by given range
    def range_paser(range, tipster)
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
                       tipster.created_at.to_date
                     else
                       90.days.ago
                   end
      start_date..end_date
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

  def create_new_tip!(params)
  end

  # Substract tipster's bankroll after published a tip
  def subtract_bankroll(amount)
  end

  def profit_in_string(include_unit = false)
    sign = '+' if @profit > 0
    "#{sign}#@profit #{I18n.t('tipster.units') if include_unit}"
  end

  def yield_in_string
    "#@yield%"
  end

  def get_statistics(params = {})
    range = self.class.parse_range_param(params)

    @current_statistics_range = range

    range = self.class.range_paser(range, self)
    tips = self.tips.paid.where(published_at: range)

    # Save the number of tip
    @number_of_tips = tips.count

    # Grouping by published date
    date_with_tips = tips.group_by(&:published_date)

    @profit_per_dates = []
    @tips_per_dates = []
    @yield = 0
    @profit = 0
    correct_tips = 0
    odds = 0
    total_amount = 0

    date_with_tips.each do |date, tips|
      @tips_per_dates << {date: date, tips_count: tips.count}
      tips.each do |tip|
        odds += tip.odds
        total_amount += tip.amount
        if tip.correct?
          correct_tips += 1
          @profit += (tip.amount*(tip.odds - 1)).round(0)
        else
          @profit -= tip.amount
        end
      end
      @profit_per_dates << {date: date, profit: @profit}
    end

    #  Cal avg of odds and hit(win) rate
    if @number_of_tips.zero?
      @hit_rate, @avg_odds, @yield = 0, 0, 0
    else
      @hit_rate = (correct_tips*100/@number_of_tips.to_f).round(1)
      @avg_odds = (odds/@number_of_tips.to_f).round(1)
      @yield = (@profit*100/total_amount.to_f).round(0)
    end
    self
  end

  #def statistics_by_month
  #  #self.tips.size
  #  dates = first_dates_of_months_since_join
  #end

  def profit_values_for_chart
    @profit_per_dates.map { |ppd| ppd[:profit] }
  end

  def profit_dates_for_chart
    @profit_per_dates.map { |ppd| ppd[:date].strftime("%b %d") }
  end

  def hit_rate_in_string
    "#@hit_rate%"
  end

  # The ratio between the number of profit months per active months
  # Return example:
  # 3/6
  def profitable_months
    "#{rand(3..6)}/#{first_dates_of_months_since_join.count}"
  end

  # Return lastest tips limit by the given quantity
  def recent_tips(quantity = 10)
    self.tips.includes([:author, :sport]).order('created_at desc').limit(quantity)
  end

  def win_rate
  end

  # Return an array of the first date of the months from tipster join date to today
  # Ex: ['2013-02-01','2013-02-01' ...]
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

  protected
  def crop_avatar
    avatar.recreate_versions! if crop_x.present?
  end

end
