class Tipster < User

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
      relation = self.process_filter_params(params)
      relation.includes(:profile)
    end

    def process_filter_params(params, relation = self)
      unless params[:sport].blank?
        relation = relation.process_sport_param(params[:sport])
      end
      unless params[:status].blank?
        relation = relation.process_status_param(params[:status])
      end
      relation
    end

    def process_sport_param(sport, relation = self)
      sport = Sport.find_by(name: sport)
      relation = relation.where(sport_id: sport.id) if sport
      relation
    end

    def process_status_param(active, relation = self)
      return relation if active.blank?
      active = (active == 'active') ? true : false
      relation = relation.where(:active => active)
      relation
    end
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  # Substract tipster's bankroll after created new tip
  def subtract(amount)

  end
end
