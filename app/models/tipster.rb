class Tipster < User
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
  has_many :tips

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
      sort_string = parse_sort_params(params)
      paging_info = parse_paging_params(params)

      # Paginate with Kaminari
      relation.includes([])
      .order(sort_string)
      .page(paging_info.page)
      .per(paging_info.page_size)
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

    protected

    # Return format
    # "field direction"
    def parse_sort_params(params)
      sort_string = params[:sort]

      sort_direction = ''
      sort_field = 'id'
      if sort_string.present?
        sort_direction = sort_string.split('_').second
        sort_field = sort_string.split('_').first
        sort_direction = (sort_direction == 'desc') ? 'asc' : 'desc'
      else
        sort_direction = DEFAULT_SORT_DIRECTION
      end
      if self.column_names.include? sort_field
        "#{sort_field} #{sort_direction} "
      else
        nil
      end
    end

    ###
    # Return PagingInfo object contains:
    #  page: the page number requested, default = 1
    #  per_page: the number of results per page
    ###
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
  def create_new_tip(params)
    klass = self.class.name
    # FootballTipster
    # FootballTip
    tip_klass = klass.gsub('Tipster', 'Tip')
    tip = tip_klass.constantize.new(params)
    tip
  end

  # Substract tipster's bankroll after published a tip
  def subtract_bankroll(amount)

  end

  # Ratio between the profit during a given period & total stakes during this period.
  # This is the yardstick for tipster's performance per bet
  def yield(range)

  end

  # Final bank - Initial bank
  def profil(range)

  end

  # The average odds is calculated as the sum of the odds of every tip from an tipster,
  # divided by the total number of tips from that tipster
  def avg_odds

  end

  # The percentage of winning tips vs total number of tips
  def win_rate

  end
end
