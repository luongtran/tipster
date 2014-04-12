class Competition < ActiveRecord::Base
  belongs_to :sport, foreign_key: :sport_code, primary_key: :code
  has_many :matches, foreign_key: :competition_uid, primary_key: :uid

  validates :sport_code, presence: true
  validates_uniqueness_of :name, scope: :sport_code
  validates_uniqueness_of :uid, scope: :sport_code

  class << self
    def seed
      raw_competitions = OddsFeed::Betclic.raw_competitions
      raw_competitions.each do |compt|
        sport_code = Sport::CODE_TO_BETCLIC_SPORT_ID.key(compt[:sport_id].to_i)
        if sport_code
          create(
              uid: compt[:id],
              name: compt[:name],
              sport_code: sport_code
          )
        end
      end
    end
  end
end
