class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :tips, :sport_id
    add_index :tips, :bet_type_id
    add_index :tips, :platform_id
  end
end
