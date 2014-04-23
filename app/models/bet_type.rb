# == Schema Information
#
# Table name: bet_types
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  sport_code :string(255)
#  name       :string(255)
#  other_name :string(255)
#  definition :string(255)
#  example    :string(255)
#  has_line   :boolean          default(TRUE)
#

class BetType < ActiveRecord::Base

  belongs_to :sport, foreign_key: :sport_code, primary_key: :code

  validates_presence_of :sport, :code, :name
  validates_uniqueness_of :code, allow_blank: true
  validates_uniqueness_of :name, scope: :sport_code, allow_blank: true

  after_create :auto_position
  class << self
    def translate_bet_type_name_to_standard(ogrinial_bet_type_name, bookmarker_code, sport_code)
      bet_type_found = recognized_bet_types(bookmarker_code, sport_code).detect do |bet_type|
        (bet_type['sport'] == sport_code) && (bet_type[bookmarker_code] == ogrinial_bet_type_name)
      end
      bet_type_found['name']
    end

    attr_accessor :raw_config

    # === Find the bet types if the given bookmarker is supported
    # Return example:
    # [
    #    {
    #        'sport' => 'soccer',                       # the code of sport
    #        'standard_code' => 'soccer_match_result',  # the standard code
    #        'standard_name' => 'Match Result',         # the standard name(display in site)
    #        'france_paris' => 'asdfasdf',              # the code on france paris
    #        'has_line' => true                         # determine the bet type is has line number or not
    #    },
    # ]
    def recognized_bet_types(bookmarker_code, sport_code = nil)
      config = raw_config
      bet_types = []
      config.each do |sport|
        sport['bet_types'].each do |bet_type|
          if bet_type[bookmarker_code].present? && !(sport_code.present? && sport_code != sport['code'])
            bet_types << {
                'sport' => sport_code,
                'standard_code' => bet_type['code'],
                'standard_name' => bet_type['name'],
                bookmarker_code => bet_type[bookmarker_code],
                'has_line' => (bet_type['has_line'] == 'yes')
            }
          end
        end
      end
      bet_types.delete_if { |e| e.blank? }
      bet_types.uniq
    end

    def raw_config
      @raw_config ||= YAML.load_file File.join(Rails.root, 'db', 'seeds', 'sports_bet_types.yml')
    end
  end

  private
  def auto_position
    if self.position.nil?
      self.position = self.id
      self.save
    end
  end
end
