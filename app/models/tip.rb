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

class Tip < ActiveRecord::Base

  BET_BOOKMARKERS = ["betclic", "bwin", "unibet", "fdj", "netbet", "france_paris"]

  belongs_to :tipster

  validates :tipster, :event, :platform, :bet_type, :odds, :selection, :advice, :stake, :amount, presence: true
  validates_length_of :event, :advice, minimum: 15
  validates_inclusion_of :platform, in: BET_BOOKMARKERS

  before_create :initial_status


  def free?
    [false, true].sample
  end

  private
  def initial_status
    self.status = 0
  end
end
