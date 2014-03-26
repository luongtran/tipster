# == Schema Information
#
# Table name: tips
#
#  id           :integer          not null, primary key
#  author_id    :integer          not null
#  author_type  :string(255)      not null
#  match_id     :integer
#  sport_id     :integer          not null
#  platform_id  :integer          not null
#  bet_type_id  :integer          not null
#  odds         :float            not null
#  selection    :string(255)      not null
#  line         :float
#  advice       :text             not null
#  amount       :integer          not null
#  correct      :boolean          default(FALSE)
#  status       :integer          not null
#  free         :boolean          default(FALSE)
#  published_by :integer
#  published_at :datetime
#  finished_at  :datetime
#  finished_by  :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Tip < ActiveRecord::Base

  STATUS_WAITING_FOR_APPROVED = 0
  STATUS_PUBLISHED = 1
  STATUS_REJECTED = 2
  STATUS_FINISHED = 3

  CREATE_PARAMS = [:platform_id, :bet_type_id, :odds, :selection, :advice, :amount, :sport_id, :line]

  attr_accessor :match_name, :bet_type_name, :bet_type_code

  # ===========================================================================
  # ASSOCIATIONS
  # ===========================================================================
  belongs_to :author, polymorphic: true
  belongs_to :sport
  belongs_to :bet_type
  belongs_to :platform
  belongs_to :match, foreign_key: :match_id, primary_key: :opta_match_id

  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================
  validates :author, :odds, :selection, :advice, :sport, :platform, :bet_type,
            :amount, presence: true
  validates_presence_of :bet_type_id, :platform_id,
                        message: 'Choose at least one'
  validates_length_of :advice, minimum: 10, allow_blank: true
  validates_numericality_of :amount, greater_than_or_equal_to: 10, less_than_or_equal_to: 100, only_integer: true
  validates_numericality_of :odds, greater_than_or_equal_to: 1.0
  #validates_presence_of :line, :if => Proc.new { self.bet_type && self.bet_type.has_line? }

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================
  before_validation :valid_beting
  before_create :init_status

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
      relation = relation.perform_date_param(params[:date])
      relation
    end

    def perform_sport_param(sport, relation = self)
      sport = Sport.find_by(code: sport)
      relation = relation.where(sport_id: sport.id) if sport
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
  end

  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================
  def to_param
    "#{self.id}-#{self.match.try(:name)}".parameterize
  end

  # Call after admin validate the tip. Send tip and subtract bankroll
  def published!
    self.update_attributes(
        published_at: Time.now,
        status: STATUS_PUBLISHED
    )
  end

  def published?
    !!self.published_at
  end

  def published_date
    self.published_at.to_date
  end

  def expired?
    self.expire_at.past?
  end

  def bet_on_in_string
    # Bet on: {Selection} [Line] {Bet type}
  end

  def profit
    ((self.amount) * (self.odds - 1)).round(0)
  end

  def status_in_string
  end

  def created_at_in_string
    DateUtils.in_time_zone(self.created_at, I18n.t('time.formats.date_with_time'))
  end

  # ===========================================================================
  # PRIVATE METHODS
  # ===========================================================================
  private
  def init_status
    self.status = STATUS_WAITING_FOR_APPROVED
  end

  def init_expire_time
    #self.expire_at = Time.now + 2.days
  end

  def valid_beting
    if self.bet_type && self.bet_type.has_line?
      self.errors[:line] = "can't be blank" unless self[:line].present?
    end
  end
end
