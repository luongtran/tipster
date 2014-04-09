class AddResultToTip < ActiveRecord::Migration
  def change
    add_column :tips, :result, :string
  end
end
