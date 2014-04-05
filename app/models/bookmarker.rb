# == Schema Information
#
# Table name: bookmarkers
#
#  id   :integer          not null, primary key
#  code :string(255)      not null
#  name :string(255)      not null
#
require 'bookmarker/betclic'
require 'bookmarker/france_paris'

class Bookmarker < ActiveRecord::Base
  validates :code, :name, uniqueness: {case_sensitive: false}
  BETCLIC = 'betclic'
  FRANCE_PARIS = 'france_paris'

  CODE_TO_CLASS = {
      BETCLIC => Betclic,
      FRANCE_PARIS => FranceParis
  }

  # Return the class responsible to feed odds from bookmarker
  def odds_feed_responsible_class
    CODE_TO_CLASS[self.code]
  end
end