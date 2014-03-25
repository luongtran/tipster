class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.integer :opta_area_id
      t.integer :parent_id
      t.string :name
      t.string :country_code
      t.boolean :active, default: true
    end
  end
end
