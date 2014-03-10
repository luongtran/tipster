class RestructiveTipTable < ActiveRecord::Migration
  def change
    remove_column :tips, :expire_at
    add_column :tips, :expire_at, :datetime
    add_column :tips, :sport_id, :integer
  end
end
