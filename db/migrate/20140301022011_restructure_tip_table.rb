class RestructureTipTable < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists?('tips')
      drop_table :tips
    end
    create_table :tips do |t|
      # Polymophic association
      t.integer :author_id
      t.string :author_type

      t.string :event, null: false # The name of match/race
      t.string :platform, null: false # bookmaker
      t.integer :bet_type, null: false # Ex: Over/Under

      t.float :odds, null: false # Best odds
      t.float :line # Only available with Over/Under bet type
      t.integer :selection, null: false # Bet on: Over 2.5

      t.text :advice, null: false
      t.float :stake, null: false # percentage
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
