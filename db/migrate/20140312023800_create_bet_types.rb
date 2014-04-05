class CreateBetTypes < ActiveRecord::Migration
  def change
    create_table :bet_types do |t|
      t.string :code
      t.string :sport_code
      t.string :name
      t.string :other_name
      t.string :definition
      t.string :example
      t.boolean :has_line, default: true

      t.index :sport_code
    end
  end
end
