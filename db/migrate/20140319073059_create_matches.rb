class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :uid
      t.integer :competition_uid
      t.string :sport_code, null: false
      t.string :name

      t.string :team_a
      t.string :team_b
      t.string :fr_name

      t.datetime :start_at
      t.timestamps
    end

    add_index :matches, :sport_code
    add_index :matches, :uid
    add_index :matches, :competition_uid
  end
end
