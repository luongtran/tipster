# == Schema Information
#
# Table name: bookmarkers
#
#  id   :integer          not null, primary key
#  code :string(255)      not null
#  name :string(255)      not null
#

class Bookmarker < ActiveRecord::Base
end

#require 'bookmarker/betclic'
#require 'bookmarker/france_paris'
#
#module Bookmarker
#  BETCLIC = 'betclic'
#  FRANCE_PARIS = 'france_paris'
#
#  BOOKMARKERS_MAP = {
#      BETCLIC => {
#          name: 'Betclic',
#          responsible_class: Bookmarker::Betclic
#      },
#      FRANCE_PARIS => {
#          name: 'France Paris',
#          responsible_class: Bookmarker::FranceParis
#      }
#  }
#  module ConfigReader
#    class << self
#      # === Find the bet types if the given bookmarker is supported
#      # Return example:
#      # [
#      #    {
#      #        'sport' => 'soccer',                       # the code of sport
#      #        'standard_code' => 'soccer_match_result',  # the standard code
#      #        'standard_name' => 'Match Result',         # the standard name(display in site)
#      #        'france_paris' => 'asdfasdf',              # the code on france paris
#      #        'has_line' => true                         # determine the bet type is has line number or not
#      #    },
#      # ]
#      def recognized_bet_types(bookmarker_code, sport_code = nil)
#        config = raw_config
#        bet_types = []
#        config.each do |sport|
#          sport['bet_types'].each do |bet_type|
#            if bet_type[bookmarker_code].present? && !(sport_code.present? && sport_code != sport['code'])
#              bet_types << {
#                  'sport' => sport_code,
#                  'standard_code' => bet_type['code'],
#                  'standard_name' => bet_type['name'],
#                  bookmarker_code => bet_type[bookmarker_code],
#                  'has_line' => (bet_type['has_line'] == 'yes')
#              }
#            end
#          end
#        end
#        bet_types.delete_if { |e| e.blank? }
#        bet_types.uniq
#      end
#
#      def raw_config
#        YAML.load_file File.join(Rails.root, 'db', 'seeds', 'sports_bet_types.yml')
#      end
#    end
#  end
#end
