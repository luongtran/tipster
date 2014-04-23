class CreateBetTypes < ActiveRecord::Migration
  def change
    create_table :bet_types do |t|
      t.string :code
      t.string :sport_code
      t.string :name
      t.boolean :has_line, default: true

      t.string :other_name
      t.text :definition
      t.text :example
      t.integer :position
      t.index :sport_code
    end
  end
end
