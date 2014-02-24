class AddSportToUser < ActiveRecord::Migration
  def change
    add_column :users, :sport_id, :integer
    add_index :users, :sport_id
  end
end
