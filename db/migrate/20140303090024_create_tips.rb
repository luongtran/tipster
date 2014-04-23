class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      # Polymophic association
      t.integer :author_id, null: false
      t.string :author_type, null: false # Admin | Tipster

      t.integer :match_id
      t.string :match_type # ManualMatch or BookmarkerMatch

      t.string :bookmarker_code, null: false
      t.string :bet_type_code, null: false # Ex: Over/Under
      t.float :odds, null: false # Best odds
      t.string :selection, null: false # Bet on: Over + 3.0

      t.text :advice, null: false
      t.integer :amount, null: false

      # After mapped
      t.string :sport_code, null: false
      t.integer :opta_match_id # column 'id' on opta_matches table
      t.integer :opta_competition_id # column 'competition_id' on opta_matches table

      t.boolean :free, default: false
      t.integer :status, null: false
      t.integer :published_by
      t.datetime :published_at

      t.integer :last_rejected_by
      t.integer :last_rejected_at
      t.text :last_reject_reason

      t.datetime :finished_at
      t.integer :finished_by

      t.timestamps
    end
    add_index :tips, [:author_id, :author_type]
    add_index :tips, :sport_code
    add_index :tips, :bet_type_code
    add_index :tips, :bookmarker_code
    add_index :tips, :match_id

    add_index :tips, :opta_match_id
    add_index :tips, :opta_competition_id

  end
end
