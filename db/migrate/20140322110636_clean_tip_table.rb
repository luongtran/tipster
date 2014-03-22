class CleanTipTable < ActiveRecord::Migration
  def change
    change_column :tips, :event, :string, null: true
  end
end
