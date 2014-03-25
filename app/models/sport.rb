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
  has_and_belongs_to_many :tipsters, -> { readonly }
  has_many :bet_types
  has_many :competitions
  has_many :seasons, through: :competitions

  validates :code, presence: true, uniqueness: {case_sensitive: false}

  after_create :auto_position

  BETCLIC_SPORT_ID = {
      'football' => 1,
      'tennis' => 2,
      'basketball' => 4,
      'rugby' => 5,
      'handball' => 9,
      'hockey' => 13,
      'football_us' => 14,
      'baseball' => 20
  }

  BETCLIC_BET_TYPE = {
      'football' => [
          {
              'code' => 'Ftb_Mr3',
              'name' => 'Match Result'
          },
          {
              'code' => 'Ftb_Csc',
              'name' => 'Correct Score'
          },
          {
              'code' => 'Ftb_Htf',
              'name' => 'Half-Time / Full-Time'
          },
          {
              'code' => 'Ftb_Htr',
              'name' => 'Half-Time Result'
          },
          {
              'code' => 'Ftb_Tgl',
              'name' => 'Total Goals'
          },
          {
              'code' => 'Ftb_Dbc',
              'name' => 'Double Chance'
          },
          {
              'code' => 'Ftb_Fts',
              'name' => 'First Team To Score'
          },
          {
              'code' => 'Ftb_Hcs',
              'name' => 'Half-Time Correct Score'
          },
          {
              'code' => 'Ftb_10',
              'name' => 'Over/Under'
          }
      ]
  }

  def icon_path
    code = self.code
    if code == 'soccer'
      code = 'football'
    end
    "/assets/sport-icons/i_#{code}.png"
  end

  private
  def auto_position
    if  self.position.nil?
      self.position = self.id
      self.save
    end
  end
end
