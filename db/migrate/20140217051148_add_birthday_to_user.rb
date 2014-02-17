class AddBirthdayToUser < ActiveRecord::Migration
  def change
    add_column :users, :birthday, :date , :null => false
  end
end
