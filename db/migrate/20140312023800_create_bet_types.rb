class CreateBetTypes < ActiveRecord::Migration
  def change
    create_table :bet_types do |t|
      t.integer :sport_id
      t.string :code
      t.string :name
      t.string :other_name
      t.string :definition
      t.string :example
      t.index :sport_id
    end
  end


  def down
    change_column :operations, :text_type_discount, :string
    change_column :operations, :discount_min, :string
    change_column :operations, :discount_level, :string
    change_column :operations, :discount_sponsor, :string
  end

end
