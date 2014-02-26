class Tipster < User

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
      #paging_info = parse_paging_params(params)
      relation.includes([])
      .order('id asc')
      .page(1)
      .per(10)
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

    def parse_sort_params
    end

    def parse_paging_params(params)
      paging_info = PagingInfo.new
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  # Test
  def tips
    tips.done.each do |t|
      if t.correct?

      else

      end
    end
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
