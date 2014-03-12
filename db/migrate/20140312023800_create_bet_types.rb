class CreateBetTypes < ActiveRecord::Migration
  def change
    create_table :bet_types do |t|
      t.integer :sport_id
      t.string :code
      t.string :name
      t.string :other_name
      t.string :definition
      t.string :example
    end
  end
end
