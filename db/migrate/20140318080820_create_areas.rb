class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :area_id
      t.string :name
      t.string :country_code
      t.string :parent_area_id
      t.boolean :active, default: true
    end
  end
end
