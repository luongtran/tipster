class CreateOptaAreas < ActiveRecord::Migration
  def change
    create_table :opta_areas do |t|
      t.integer :opta_area_id
      t.string :name
      t.string :country_code
      t.datetime :update_at
    end
  end
end
