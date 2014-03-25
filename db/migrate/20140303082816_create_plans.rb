class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :title
      t.integer :reception_delay, default: 0
      t.text :description
      t.boolean :pause_ability, default: true
      t.boolean :switch_tipster_ability, default: true
      t.boolean :profit_guaranteed, default: true
      t.float :discount, default: 0
      t.float :price
      t.integer :number_tipster
      t.integer :period
      t.float :adding_price
      t.timestamps
    end
  end
end
