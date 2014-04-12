class Tip < ActiveRecord::Base

  STATUS_PENDING = 0
  STATUS_PUBLISHED = 1
  STATUS_REJECTED = 2
  STATUS_FINISHED = 3

  RESULT_WIN = 'win'
  RESULT_LOSE = 'lose'
  RESULT_VOID = 'void' # only with handicap bets

  STATUSES_MAP = {
      STATUS_PENDING => 'pending',
      STATUS_PUBLISHED => 'published',
      STATUS_REJECTED => 'rejected',
      STATUS_FINISHED => 'finished'
  }

  CREATE_PARAMS = [:bookmarker_code, :bet_type_code, :sport_code, :odds, :selection, :advice, :amount]
  attr_accessor :match_name, :bet_type_name
  # ===========================================================================
  # ASSOCIATIONS
  # ===========================================================================
  belongs_to :author, polymorphic: true

  # I don't trust the id of record :)
  belongs_to :sport, foreign_key: :sport_code, primary_key: :code
  belongs_to :bet_type, foreign_key: :bet_type_code, primary_key: :code
  belongs_to :bookmarker, foreign_key: :bookmarker_code, primary_key: :code
  belongs_to :match, foreign_key: :match_uid, primary_key: :uid

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================
  validates :author, :odds, :selection, :advice, :sport, :bookmarker, :bet_type, :amount, presence: true

  validates_presence_of :bet_type_code, :bookmarker_code, message: 'Choose at least one'

  validates_length_of :advice, minimum: 50, allow_blank: true
  validates_numericality_of :amount, greater_than_or_equal_to: 10, less_than_or_equal_to: 100, only_integer: true
  validates_numericality_of :odds, greater_than_or_equal_to: 1.0

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================
  before_create :init_status
  after_create :write_event_created

  # ===========================================================================
  # SCOPE
  # ===========================================================================
  scope :published, -> { where(status: STATUS_PUBLISHED) }
  scope :paid, -> { where(free: false) }
  scope :free, -> { where(free: true) }
  scope :correct, -> { where(correct: true) }
  scope :finished, -> { where(status: STATUS_FINISHED) }
  scope :moneyable, -> { where(free: false, status: STATUS_FINISHED) }

  delegate :name, to: :sport, prefix: true
  delegate :name, to: :match, prefix: true
  delegate :name, to: :bet_type, prefix: true
  delegate :full_name, to: :author, prefix: true
  # ===========================================================================
  # Class METHODS
  # ===========================================================================
  class << self
    # Find tips by given author and also search and filter
    def by_author(author, params)
      where(author_id: author, author_type: author.class.name).load_data(params)
    end

    def load_data(params = {}, relation = self)
      relation = perform_filter_params(params)
      result = relation.includes(:author, :sport, :bet_type, :match).order('created_at desc')
    end

    def perform_filter_params(params, relation = self)
      unless params[:sport].blank?
        relation = relation.perform_sport_param(params[:sport])
      end
      unless params[:status].blank?
        relation = relation.perform_status_param(params[:status])
      end
      relation = relation.perform_date_param(params[:date])
      relation
    end

    def perform_sport_param(sport, relation = self)
      sport = Sport.find_by(code: sport)
      relation = relation.where(sport_code: sport.code) if sport
      relation
    end

    def perform_status_param(status, relation = self)
      status_code = STATUSES_MAP.index(status)
      if status_code
        relation = relation.where(status: status_code)
      end
      relation
    end

    # Search tips created on the given date
    def perform_date_param(date, relation = self)
      begin
        date = date.to_date
      rescue => e
        date = Date.today
      end
      relation = relation.where(created_at: date.beginning_of_day..date.end_of_day)
      relation
    end

    def recent_finished(count = 10)
      self.finished.order('created_at desc').limit(count)
    end
  end

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================
  def to_param
    "#{self.id}-#{self.match.try(:name)}".parameterize
  end

  # Call admin validate the bet and match of tip is valid.
  # Do send tip and subtract bankroll
  def published!(admin)
    unless admin.is_a? Admin
      raise "The tip can not publish by #{admin.class.name}"
    end
    self.update_attributes!(
        published_at: Time.now,
        status: STATUS_PUBLISHED,
        published_by: admin.id
    )
    TipJournal.write_event_published(self, admin)
    # Do sending SMS, email
  end

  # Params:
  #  * admin(Admin): the admin has rejected the tip
  #  * reason(string): the reason string
  def reject!(admin, reason)
    unless admin.is_a?(Admin)
      raise "The author object must be a Admin."
    end
    update_status(STATUS_REJECTED)
    update_column :reject_reason, reason
    TipJournal.write_event_rejected(self, admin)
  end

  # Params:
  #  * admin(Admin): the admin has rejected the tip
  #  * result(boolean): the tip is win | lose
  def finnish!(admin, result)
    unless admin.is_a?(Admin)
      raise "The author object must be a Admin."
    end
    self.update_attributes!(
        finished_at: Time.now,
        finished_by: admin.id,
        status: STATUS_FINISHED
    )
    TipJournal.write_event_finished(self, admin)
  end


  def published_date
    self.published_at.to_date
  end

  def profit
    if self.correct?
      ((self.amount) * (self.odds - 1)).round(0)
    else
      -self.amount
    end
  end

  def status_in_string
    I18n.t("tip.statuses.#{STATUSES_MAP[self.status]}")
  end

  def created_at_in_string
    DateUtil.in_time_zone(self.created_at, I18n.t('time.formats.date_with_time'))
  end

  def published_at_in_string
    DateUtil.in_time_zone(self.published_at, I18n.t('time.formats.date_with_time'))
  end

  # Check the current status of tip
  def published?
    # He I don't use the static attr because a finished tip is also published
    !!self.published_at
  end

  # Check the current status of tip
  def rejected?
    self.status == STATUS_REJECTED
  end

  alias_method :resubmitable?, :rejected?

  # Check the current status of tip
  def finished?
    self.status == STATUS_FINISHED
  end

  # Check the tip can be publish or not
  def publishable?
    self.status == STATUS_PENDING
  end

  alias_method :rejectable?, :publishable?

  # Check the tip can be finish or not
  def finishable?
    self.status == STATUS_PUBLISHED
  end

  # ===========================================================================
  # PRIVATE METHODS
  # ===========================================================================
  private
  def update_status(status)
    self.update_attributes! status: status
  end

  def write_event_created
    TipJournal.write_event_created(self, self.author)
  end

  def init_status
    self.status = STATUS_PENDING
  end

end
