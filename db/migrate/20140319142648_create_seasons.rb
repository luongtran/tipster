class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.integer :opta_season_id
      t.integer :opta_competition_id
      t.string :name
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
    add_index :seasons, [:opta_season_id]
    add_index :seasons, [:opta_competition_id]
  end
end
