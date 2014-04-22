# == Schema Information
#
# Table name: bookmarkers
#
#  id   :integer          not null, primary key
#  code :string(255)      not null
#  name :string(255)      not null
#

class Bookmarker < ActiveRecord::Base
  BETCLIC = 'betclic'
  FRANCE_PARIS = 'france_paris'
  BWIN = 'bwin'
  NETBET = 'netbet'

  ODDS_FEED_MODULES = {
      BETCLIC => OddsFeed::Betclic,
      NETBET => OddsFeed::Netbet,
  }
  has_many :matches, class_name: BookmarkerMatch, foreign_key: :bookmarker_code,
           primary_key: :code

  validates :code, :name, uniqueness: {case_sensitive: false}

  class << self
    # Return the odds feed module corresponding with given bookmarker
    def find_odds_feed_module_by(bookmarker_code)
      ODDS_FEED_MODULES[bookmarker_code]
    end

    def able_to_odds_feed
      where(code: ODDS_FEED_MODULES.keys)
    end
  end

  def find_available_matches(params= {})
    self.matches.betable(params)
  end

  # Get matches from XML and save to DB
  def update_matches
    odds_feed_module = self.class.find_odds_feed_module_by(self.code)
    if odds_feed_module
      matches = odds_feed_module.recognized_matches
      matches.each do |match_attrs|
        BookmarkerMatch.create match_attrs.merge bookmarker_code: self.code
      end
    end
  end
end