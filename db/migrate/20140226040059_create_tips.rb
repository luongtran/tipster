class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      t.integer :tipster_id, null: false
      t.string :event, null: false # The name of match/race
      t.integer :platform, null: false
      t.integer :bet_type, null: false # Ex: Over/Under

      t.float :odds, null: false
      t.float :line # Only available with Over/Under bet type
      t.integer :selection, null: false # Bet on: Over 2.5
      t.text :advice, null: false
      t.float :stake, null: false # percentage
      t.float :liability, null: false # percentage
      t.integer :amount, null: false

      t.boolean :correct, default: false
      t.integer :status, null: false
      t.integer :published_by
      t.datetime :published_at
      t.timestamps
    end
    add_index :tips, :tipster_id
  end
end