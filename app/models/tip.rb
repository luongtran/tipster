# == Schema Information
#
# Table name: tips
#
#  id           :integer          not null, primary key
#  author_id    :integer
#  author_type  :string(255)
#  event        :string(255)      not null
#  expire_at    :string(255)      not null
#  platform     :string(255)      not null
#  bet_type     :integer          not null
#  odds         :float            not null
#  selection    :integer          not null
#  line         :float
#  advice       :text             not null
#  amount       :integer          not null
#  correct      :boolean          default(FALSE)
#  status       :integer          not null
#  free         :boolean          default(FALSE)
#  published_by :integer
#  published_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

=begin
  ==> This is a example of tip information
  bet_type: "Asian handicap"
  bookmaker: "Bet365"
  bookmaker_key: "bet365"
  category_slug: "european-cups"
  comment: "A Madrid are one of the best teams in Europe right now and Costa
  can cause so many problems for an inconsistent defence like Milan"
  created_at: "2014-02-19 09:30:08"
  created_at_ts: 1392798608
  event_date: "19/02 20:45"
  event_date_ts: 1392839100
  id: "300993"
  is_qualified: true
  liability: "16% bankroll (325 units)"
  login: "soccerpix"
  name: "AC MILAN vs ATLETICO MADRID"
  odds: "4.25"
  profit: "-100"
  result: "l"
  result_txt: ""
  score: "0:1"
  selection: "ATLETICO MADRID -1.50"
  sport_slug: "football"
  sportk: "football"
  stake: "5% bankroll (100 units)"
  tipster: "soccerpix"
  tournament_name: "UEFA Champions League"
=end

class Tip < ActiveRecord::Base

  STATUS_WAITING_FOR_APPROVED = 0
  STATUS_APPROVED = 1
  STATUS_REJECTED = 2
  STATUS_EXPIRED = 3

  # ===========================================================================
  # ASSOCIATIONS
  # ===========================================================================
  belongs_to :author, polymorphic: true
  belongs_to :sport
  belongs_to :bet_type
  belongs_to :platform
  # ===========================================================================
  # VALIDATIONS
  # ===========================================================================
  validates :author, :odds, :selection, :advice, :sport, :platform, :bet_type,
            :amount, presence: true
  validates_presence_of :bet_type_id, :platform_id, :event,
                        message: 'Choose at least one'
  validates_length_of :event, :advice, minimum: 10, allow_blank: true

  # ===========================================================================
  # CALLBACKS
  # ===========================================================================
  before_validation :init_status, on: :create
  #before_create :init_expire_time

  # ===========================================================================
  # SCOPE
  # ===========================================================================
  scope :published, -> { where(status: STATUS_APPROVED) }
  scope :paid, -> { where(free: false) }
  scope :free, -> { where(free: true) }
  scope :correct, -> { where(correct: true) }

  delegate :name, to: :sport, prefix: true
  # ===========================================================================
  # Class METHODS
  # ===========================================================================
  class << self
    def by_author(author, params)
      where(author_id: author, author_type: author.class.name).load_data(params)
    end

    def load_data(params, relation = self)
      relation = perform_filter_params(params)
      result = relation.includes([:author, :sport, :bet_type])
    end

    def perform_filter_params(params, relation = self)
      unless params[:sport].blank?
        relation = relation.perform_sport_param(params[:sport])
      end
      relation = relation.perform_date_param(params[:date])
      relation
    end

    def perform_sport_param(sport, relation = self)
      sport = Sport.find_by(name: sport)
      relation = relation.where(sport_id: sport.id) if sport
      relation
    end

    def perform_date_param(date, relation = self)
      begin
        date = date.to_date
      rescue => e
        date = Date.today
      end
      relation = relation.where(published_at: date.beginning_of_day..date.end_of_day)
      relation
    end
  end
  # ===========================================================================
  # INSTANCE METHODS
  # ===========================================================================
  def to_param
    "#{self.id}-#{self.event.parameterize}"
  end

  def free?
    [false, true].sample
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

  private
  def init_status
    self.status = 0
  end

  def init_expire_time
    #self.expire_at = Time.now + 2.days
  end
end
