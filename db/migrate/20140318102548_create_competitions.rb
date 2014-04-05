class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.integer :opta_competition_id
      t.integer :opta_area_id
      t.string :sport_code
      t.string :name
      t.string :fr_name
      t.boolean :active, default: true
    end
    add_index :competitions, :opta_competition_id
    add_index :competitions, :opta_area_id
    add_index :competitions, :sport_code
  end
end
