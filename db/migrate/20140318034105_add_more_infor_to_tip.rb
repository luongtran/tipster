class AddMoreInforToTip < ActiveRecord::Migration
  def change
    add_column :tips, :match_id, :integer
    add_column :tips, :match_name, :string
    add_column :tips, :match_date, :datetime
    add_column :tips, :league_id, :string
    add_column :tips, :area_id, :string
  end
end
