class AddPositionToSport < ActiveRecord::Migration
  def change
    add_column :sports, :position, :integer
  end
end
