class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.integer :uid
      t.string :name
      t.string :sport_code
      t.string :fr_name
    end
    add_index :competitions, :sport_code
    add_index :competitions, :uid, unique: true
  end
end
