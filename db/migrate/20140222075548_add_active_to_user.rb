class AddActiveToUser < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, default: true, after: :locked_at
  end
end
