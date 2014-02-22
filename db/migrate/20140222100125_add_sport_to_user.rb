class AddSportToUser < ActiveRecord::Migration
  def change
    add_column :users, :sport_id, :integer
  end
end
