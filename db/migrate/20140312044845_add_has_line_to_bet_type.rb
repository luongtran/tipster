class AddHasLineToBetType < ActiveRecord::Migration
  def change
    add_column :bet_types, :has_line, :boolean, default: true
  end
end
