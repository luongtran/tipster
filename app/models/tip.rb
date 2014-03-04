=begin
  bet_type: "Asian handicap"
  bookmaker: "Bet365"
  bookmaker_key: "bet365"
  category_slug: "european-cups"
  comment: "A Madrid are one of the best teams in Europe right now and Costa can cause so many problems for an inconsistent defence like Milan,
      Madrid to win by 2 or more."
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

  BET_BOOKMARKERS = ["betclic", "bwin", "unibet", "fdj", "netbet", "france_paris"]

  OVER_UNDER = 0
  ASIAN_HANDICAP = 1
  MATCH_ODDS = 2

  BET_TYPES_MAP = {
      OVER_UNDER => 'Over/Under',
      ASIAN_HANDICAP => 'Asian Handicap',
      MATCH_ODDS => 'Match Odds'
  }

  belongs_to :author, polymorphic: true

  validates :author, :event, :platform, :bet_type, :odds, :selection, :advice, :stake, :amount, presence: true
  validates_length_of :event, :advice, minimum: 10
  validates_inclusion_of :platform, in: BET_BOOKMARKERS
  validates_inclusion_of :bet_type, in: BET_TYPES_MAP.keys

  before_validation :init_status, :init_amount, on: :create

  before_create :init_expire_time
  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def free?
    [false, true].sample
  end

  def bet_on_in_string
    # Bet on: {Selection} [Line] {Bet type}
  end

  def bet_type_in_string
    BET_TYPES_MAP[self.bet_type]
  end

  private
  def init_status
    self.status = 0
  end

  def init_amount
    self.amount = 2000*self.stake/100 if self.stake
  end

  def init_expire_time
    self.expire_at = Time.now + 2.days
  end
end
