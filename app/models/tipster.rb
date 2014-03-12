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

  RANKING_RANGES = [
      OVERALL = 'overall',
      LAST_12_MONTHS = 'last-12-months',
      LAST_6_MONTHS = 'last-6-months',
      LAST_3_MONTHS = 'last-3-months',
      LAST_MONTH = 'last-month'
  ]
  DEFAULT_RANKING_RANGE = LAST_3_MONTHS

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessor :number_of_tips, :hit_rate, :avg_odds, :profit, :yield, :profit_per_months, :profit_per_days
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
        tipster.get_statistics(parse_range_param(params))
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
        LAST_6_MONTHS
      end
    end

    def top_rank_in_range(range)
      case range
        when LAST_MONTH
          # 30 days
        when LAST_3_MONTHS
          # 90 days
        when LAST_6_MONTHS
          # 180 days
        when LAST_YEAR
          # 365 days
        else
          # Overall ?
      end
    end

    # Find the top 3(profit) of the last week
    def find_top_3_last_week(params)
      relation = self.limit(3)
      unless params[:sport].blank?
        relation = relation.perform_sport_param(params[:sport])
      end
      relation.includes([:account])
    end


    # Return the start & end date specify by given range
    def parse_range(range = LAST_MONTH)
      end_date = Date.today
      start_date = case range
                     when LAST_MONTH
                       30.days.ago(end_date)
                     when LAST_3_MONTHS
                       90.days.ago(end_date)
                     when LAST_6_MONTHS
                       180.days.ago(end_date)
                     when LAST_12_MONTHS
                       365.days.ago(end_date)
                     else
                       return nil
                   end
      [start_date, end_date]
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
          params[:sort],
          default_sort_by: DEFAULT_SORT_FIELD,
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
    sign = if @profit > 0
             '+'
           elsif @profit < 0
             '-'
           else
             ''
           end
    "#{sign}#@profit #{I18n.t('tipster.units') if include_unit}"
  end

  def yield_in_string
    "#@yield %"
  end

  def get_statistics(range = LAST_6_MONTHS)
    range = self.class.parse_range(range)

    if range.nil?
      range = [self.created_at.to_date, Date.today]
    end
    tips = self.tips.paid.where(created_at: range.first..range.second)

    # Save the number of tip
    @number_of_tips = tips.count

    @yield = 0
    @profit = 0
    correct_tips = 0

    odds = 0
    total_amount = 0

    tips.each do |tip|
      odds += tip.odds
      total_amount += tip.amount
      if tip.correct?
        correct_tips += 1
        @profit += (tip.amount*tip.odds).round(0)
      else
        @profit -= tip.amount
      end
    end

    # # Cal avg of odds and hit(win) rate
    if @number_of_tips.zero?
      @hit_rate, @avg_odds, @yield = 0, 0, 0
    else
      @hit_rate = (correct_tips*100/@number_of_tips.to_f).round(1)
      @avg_odds = (odds/@number_of_tips.to_f).round(1)
      @yield = (@profit*100/total_amount.to_f).round(0)
    end
  end

  def hit_rate_in_string
    "#{hit_rate}%"
  end

  # The average odds is calculated as the sum of the odds of every tip from an tipster,
  # divided by the total number of tips from that tipster
  #def avg_odds(range = nil)
  #  rand(0..5)
  #end

  # The ratio between the number of profit months per active months
  # Return example:
  # 3/6
  def profitable_months
    "#{rand(3..6)}/#{rand(6..8)}"
  end

  # Return lastest tips limit by the given quantity
  def recent_tips(quantity = 10)
    self.tips.order('created_at desc').limit(quantity)
  end

  def win_rate

  end

  # Return the tips on the given date
  def tips_on_the_date(date)
  end

  def profit_per_months(range = nil)
    (5..30).to_a
    #[4, 5, 6, 7, 8, 9, 10, 11, 9, 6, 7, 5, 5, 9].sample(15).map { |n| n * 10 }
    # [20,21]
  end

  protected
  def crop_avatar
    avatar.recreate_versions! if crop_x.present?
  end

end
