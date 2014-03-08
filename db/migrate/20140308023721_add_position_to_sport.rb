class AddPositionToSport < ActiveRecord::Migration
  def change
    add_column :sports, :position, :integer
    # FIXME: this is temporally, move it to seed
    Sport.all.each do |s|
      s.update_column :position, s.id
    end
  end
end
