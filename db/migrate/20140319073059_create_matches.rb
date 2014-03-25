class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :opta_match_id
      t.integer :sport_id
      t.integer :opta_competition_id

      t.string :team_a
      t.string :team_b

      t.string :name

      t.string :betclic_match_id
      t.string :betclic_event_id

      t.datetime :start_at
      t.string :status

      t.timestamps
    end

    add_index :matches, :opta_match_id
    add_index :matches, :opta_competition_id
    add_index :matches, :sport_id
  end
end
