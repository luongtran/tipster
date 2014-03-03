class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      # Polymophic association
      t.integer :author_id
      t.string :author_type

      t.string :event, null: false # The name of match/race
      t.string :expire_at, null: false

      t.string :platform, null: false # bookmaker
      t.integer :bet_type, null: false # Ex: Over/Under

      t.float :odds, null: false # Best odds

      t.integer :selection, null: false # Bet on: Over
      t.float :line # Available only in Over/Under bet type (Ex: +2.5, 0.25 ...)

      t.text :advice, null: false
      t.float :stake, null: false # percentage of bankroll
      t.integer :amount, null: false

      t.boolean :correct, default: false
      t.integer :status, null: false

      t.boolean :free, default: false

      t.integer :published_by
      t.datetime :published_at

      t.timestamps
    end
    add_index :tips, [:author_id, :author_type]
  end
end
