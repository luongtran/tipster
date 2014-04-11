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

  CODE_TO_MODULE = {
      BETCLIC => OddsFeed::Betclic,
      FRANCE_PARIS => OddsFeed::FranceParis,
  }

  class << self
    def find_odds_feed_module_by(bookmarker_code)
      CODE_TO_MODULE[bookmarker_code]
    end
  end
  # Return the class responsible to feed odds for bookmarker
  def odds_feed_module
    CODE_TO_MODULE[self.code]
  end
end