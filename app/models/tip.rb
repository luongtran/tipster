# == Schema Information
#
# Table name: tips
#
#  id           :integer          not null, primary key
#  tipster_id   :integer          not null
#  event        :string(255)      not null
#  platform     :string(255)      not null
#  bet_type     :integer          not null
#  odds         :float            not null
#  line         :float
#  selection    :integer          not null
#  advice       :text             not null
#  stake        :float            not null
#  amount       :integer          not null
#  correct      :boolean          default(FALSE)
#  status       :integer          not null
#  published_by :integer
#  published_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

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

  belongs_to :author, polymorphic: true

  validates :tipster, :event, :platform, :bet_type, :odds, :selection, :advice, :stake, :amount, presence: true
  validates_length_of :event, :advice, minimum: 15
  validates_inclusion_of :platform, in: BET_BOOKMARKERS

  before_create :initial_status


  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def free?
    [false, true].sample
  end

  def bet_on_in_string
    # Bet on: {Selection} [Line] {Bet type}
  end

  private
  def initial_status
    self.status = 0
  end
end
