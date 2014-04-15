# == Schema Information
#
# Table name: sports
#
#  id       :integer          not null, primary key
#  name     :string(255)      not null
#  code     :string(255)      not null
#  position :integer
#

class Sport < ActiveRecord::Base

  has_many :sports_tipsters, class_name: SportsTipsters, foreign_key: :sport_code, primary_key: :code
  has_many :tipsters, through: :sports_tipsters #, primary_key: :code

  has_many :bet_types, foreign_key: :sport_code, primary_key: :code
  has_many :competitions, foreign_key: :sport_code, primary_key: :code

  has_many :opta_competitions, class_name: Opta::Competition, foreign_key: :sport_code, primary_key: :code

  has_many :matches, foreign_key: :sport_code, primary_key: :code
  validates :code, presence: true, uniqueness: {case_sensitive: false}

  belongs_to :tips, foreign_key: :sport_code, primary_key: :code

  after_create :auto_position

  CODE_TO_BETCLIC_SPORT_ID = {
      'soccer' => 1,
      'tennis' => 2,
      'basketball' => 4,
      'rugby' => 5,
      'handball' => 9,
      'hockey' => 13,
      'football_us' => 14,
      'baseball' => 20
  }

  private
  def auto_position
    if self.position.nil?
      self.position = self.id
      self.save
    end
  end
end
