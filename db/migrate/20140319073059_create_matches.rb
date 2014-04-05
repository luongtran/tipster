class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :opta_match_id, null: false
      t.string :sport_code, null: false
      t.integer :opta_competition_id

      t.string :team_a
      t.string :team_b

      t.string :name

      t.datetime :start_at, null: false
      t.string :status

      t.timestamps
    end

    add_index :matches, :opta_match_id
    add_index :matches, :opta_competition_id
    add_index :matches, :sport_code
  end
end
