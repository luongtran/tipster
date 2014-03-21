class AddMoreColumnToBetType < ActiveRecord::Migration
  def change
    add_column :bet_types, :betclic_code, :string
  end
end
