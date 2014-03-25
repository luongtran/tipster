class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      # Polymophic association
      t.integer :author_id, null: false
      t.string :author_type, null: false
      t.integer :match_id

      t.integer :sport_id, null: false

      t.integer :platform_id, null: false # bookmaker

      t.integer :bet_type_id, null: false # Ex: Over/Under

      t.float :odds, null: false # Best odds

      t.string :selection, null: false # Bet on: Over
      t.float :line # Available only in Over/Under bet type (Ex: +2.5, 0.25 ...)

      t.text :advice, null: false
      t.integer :amount, null: false

      t.boolean :correct, default: false
      t.integer :status, null: false

      t.boolean :free, default: false

      t.integer :published_by
      t.datetime :published_at

      t.datetime :finished_at
      t.integer :finished_by

      t.timestamps
    end
    add_index :tips, [:author_id, :author_type]
    add_index :tips, :sport_id
    add_index :tips, :bet_type_id
    add_index :tips, :platform_id
    add_index :tips, :match_id

  end
end
