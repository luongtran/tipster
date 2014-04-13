# == Schema Information
#
# Table name: bookmarkers
#
#  id   :integer          not null, primary key
#  code :string(255)      not null
#  name :string(255)      not null
#

class Bookmarker < ActiveRecord::Base
  validates :code, :name, uniqueness: {case_sensitive: false}
  BETCLIC = 'betclic'
  FRANCE_PARIS = 'france_paris'
  BWIN = 'bwin'

  ODDS_FEED_MODULES = {
      BETCLIC => OddsFeed::Betclic,
      FRANCE_PARIS => OddsFeed::FranceParis,
  }

  class << self
    def find_odds_feed_module_by(bookmarker_code)
      ODDS_FEED_MODULES[bookmarker_code]
    end
  end
end