class CreateOptaMatchMatches < ActiveRecord::Migration
  def change
    create_table :opta_matches do |t|
      t.integer :opta_match_id
      t.string :type # Soccer, Tennis
      t.string :name
      t.string :sport_code
      t.datetime :start_at
      t.datetime :updated_at

      # Indexing
      t.index :opta_match_id
      t.index :sport_code
    end
  end
end
