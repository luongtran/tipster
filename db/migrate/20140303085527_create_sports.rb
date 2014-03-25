class CreateSports < ActiveRecord::Migration
  def change
    create_table :sports do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :position
    end
  end
end
