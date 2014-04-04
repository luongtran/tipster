# == Schema Information
#
# Table name: bet_types
#
#  id           :integer          not null, primary key
#  sport_id     :integer
#  code         :string(255)
#  name         :string(255)
#  has_line     :boolean          default(TRUE)
#  other_name   :string(255)
#  definition   :string(255)
#  example      :string(255)
#

class BetType < ActiveRecord::Base
  belongs_to :sport
  validates_presence_of :sport, :code, :name
  validates_uniqueness_of :code, :name, allow_blank: true


  MAP = {
      'soccer_match_odds' => [
          Bookmarker::BETCLIC => 'Ftb_Mr3',
          Bookmarker::FRANCE_PARIS => ''
      ],
      'soccer_match_odds_ht' => [
          Bookmarker::BETCLIC => '',
          Bookmarker::FRANCE_PARIS => ''
      ],
      'soccer_over_under' => [
          Bookmarker::BETCLIC => 'Ftb_10',
          Bookmarker::FRANCE_PARIS => ''
      ],
      'soccer_over_under_ht' => [
          Bookmarker::BETCLIC => 'Ftb_10',
          Bookmarker::FRANCE_PARIS => ''
      ],
      'soccer_european_handicap' => [
          Bookmarker::BETCLIC => 'Ftb_10',
          Bookmarker::FRANCE_PARIS => ''
      ],
      'soccer_european_handicap_ht' => [
          Bookmarker::BETCLIC => 'Ftb_10',
          Bookmarker::FRANCE_PARIS => ''
      ],
      'asian_handicap' => [
          Bookmarker::BETCLIC => 'Ftb_10',
          Bookmarker::FRANCE_PARIS => ''
      ],
      'asian_handicap_ht' => [

      ]
  }

  class << self
    # Find and mapped bet types on the given bookmarker
    def bet_types_support_with(bookmarker_code)
      MAP[bookmarker_code]
    end
  end

  def other_names
    MAP[self.code]
  end

end
