class CreateOptaSeasons < ActiveRecord::Migration
  def change
    create_table :opta_seasons do |t|
      t.integer :opta_season_id
      t.integer :opta_competition_id
      t.string :name
      t.datetime :start_at
      t.datetime :end_at

      t.datetime :updated_at

      # Indexing
      t.index :opta_season_id
      t.index :opta_competition_id
    end
  end
end
