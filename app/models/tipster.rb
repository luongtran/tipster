class Tipster < ActiveRecord::Base
  DEFAULT_PAGE_SIZE = 20
  DEFAULT_SORT_FIELD = 'profit'

  RANKING_RANGES = [
      LAST_MONTH = 'last-month',
      LAST_3_MONTHS = 'last-3-months',
      LAST_6_MONTHS = 'last-6-months',
      LAST_YEAR = 'last-year'
  ]

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

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

  def create_new_tip(params)
    #klass = self.class.name
    #tip_klass = klass.gsub('Tipster', 'Tip')
    #tip = tip_klass.constantize.new(params)
    #tip
  end

  # Substract tipster's bankroll after published a tip
  def subtract_bankroll(amount)
  end

  # Ratio between the profit during a given period & total stakes during this period.
  # This is the yardstick for tipster's performance per bet
  def yield(range = nil)
    self.id * [1, -1].sample
  end

  # Final bank - Initial bank
  def profit(range = nil)
    self.id * 1000
  end

  # The average odds is calculated as the sum of the odds of every tip from an tipster,
  # divided by the total number of tips from that tipster
  def avg_odds(range = nil)
    rand(0..5)
  end

  # The percentage of winning tips vs total number of tips
  def win_rate(range = nil)
  end

  # The ratio between the number of profit months per active months
  # Return example:
  # 3/6
  def profitable_months
    "#{rand(3)}/#{rand(1..6)}"
  end

  # Return lastest tips limit by the given quantity
  def recent_tips(quantity = 10)
    self.tips.limit(quantity)
  end

  # Return the tips on the given date
  def tips_on_the_date(date)
  end

  # Return the number of tips on the given range
  def tips_count(range = nil)
    self.id * 5
  end

  def profit_per_months(range = nil)
    (10..100).to_a.sample(15)
  end

  protected
  def crop_avatar
    avatar.recreate_versions! if crop_x.present?
  end

end
