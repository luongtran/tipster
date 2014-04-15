class Opta::Area < ActiveRecord::Base

  # The assoction is not necessary because we don't find competitions form area
  has_many :competitions, class_name: Opta::Competition, foreign_key: :opta_area_id, primary_key: :opta_area_id

  validates :opta_area_id, uniqueness: true
  validates :name, presence: true

  class << self
    def initialize_data
      # Choose soccer to get full of areas in OPTA database
      fetcher = OptaSport::Fetcher.soccer
      res = fetcher.get_areas
      res.all.each do |area_attrs|
        create area_attrs
      end
    end
  end
end
