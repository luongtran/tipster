class Tipster < User
  include TipCreatable

  DEFAULT_PAGE_SIZE = 20
  DEFAULT_SORT_DIRECTION = 'desc'

  RANKING_RANGES = [
      LAST_MONTH = 'last-month',
      LAST_3_MONTHS = 'last-3-months',
      LAST_6_MONTHS = 'last-6-months',
      LAST_YEAR = 'last-year'
  ]

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :sport

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================
  validates :sport, presence: true

  # ==============================================================================
  # SCOPE
  # ==============================================================================
  scope :active, -> { where(active: true) }

  # ==============================================================================
  # CLASS METHODS
  # ==============================================================================
  class << self
    def load_data(params = {})
      relation = self.perform_filter_params(params)
      sorting_info = parse_sort_params(params)

      # paging_info = parse_paging_params(params)
      # Paginate with Kaminari
      #relation.includes([])
      #.order(sort_string)
      #.page(paging_info.page)
      #.per(paging_info.page_size)

      result = relation.includes([:profile])
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
      relation = relation.where(sport_id: sport.id) if sport
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
          # From begin?
      end
    end

    # ==============================================================================
    # PROTECTED METHODS
    # ==============================================================================
    protected

    # Return SortingInfo object contains:
    #  sort_by: the name of column|field
    #  direction: asc | desc
    def parse_sort_params(params)
      sort_string = params[:sort]
      sort_direction = ''
      sort_field = 'id'

      if sort_string.present?
        sort_direction = sort_string.split('_').last
        sort_field = sort_string.gsub(/(_desc|_asc)/, '')
      else
        sort_direction = DEFAULT_SORT_DIRECTION
      end

      SortingInfo.new(
          sort_by: sort_field,
          direction: sort_direction
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
    "#{self.id}-#{self.name}".parameterize
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
  def profil(range = nil)
    self.id * 1000
  end

  # The average odds is calculated as the sum of the odds of every tip from an tipster,
  # divided by the total number of tips from that tipster
  def avg_odds(range = nil)
  end

  # The percentage of winning tips vs total number of tips
  def win_rate(range = nil)
  end

  # The ratio between the number of profil months per active months
  # Return example:
  # 3/6
  def profitable_months
  end

  # Return lastest tips limit by the given quantity
  def recent_tips(quantity = nil)
  end

  # Return the tips on the given date
  def tips_on_the_date(date)
  end

  # Return the number of tips on the given range
  def tips_count(range = nil)
    self.id * (5..15).to_a.sample
  end
end
