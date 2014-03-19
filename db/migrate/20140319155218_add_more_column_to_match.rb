class AddMoreColumnToMatch < ActiveRecord::Migration
  def change
    remove_column :matches, :played
    remove_column :matches, :optasport_match_id
    add_column :matches, :match_id, :string
    add_column :matches, :status, :string
  end
end
