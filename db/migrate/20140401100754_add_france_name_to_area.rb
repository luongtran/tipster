class AddFranceNameToArea < ActiveRecord::Migration
  def change
    add_column :areas, :fr_name, :string
  end
end
