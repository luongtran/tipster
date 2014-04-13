class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string :bookmarker_code
      t.integer :competition_id
      t.string :sport_code, null: false
      t.string :name

      t.string :team_a
      t.string :team_b
      t.string :fr_name

      t.datetime :start_at
      t.timestamps
    end

    add_index :matches, :sport_code
    add_index :matches, :competition_id
  end
end
