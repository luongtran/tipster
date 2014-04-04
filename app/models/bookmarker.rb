require 'bookmarker/betclic'
require 'bookmarker/france_paris'
module Bookmarker
  BETCLIC = 'betclic'
  FRANCE_PARIS = 'france_paris'

  BOOKMARKERS_MAP = {
      BETCLIC => {
          name: 'Betclic',
          responsible_class: Bookmarker::Betclic
      },
      FRANCE_PARIS => {
          name: 'France Paris',
          responsible_class: Bookmarker::FranceParis
      }
  }
end