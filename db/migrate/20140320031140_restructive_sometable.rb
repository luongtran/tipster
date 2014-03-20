class RestructiveSometable < ActiveRecord::Migration
  def change
    # Restructive matches
    drop_table :matches
    create_table :matches do |t|
      t.string :opta_competition_id
      t.string :opta_match_id

      t.string :betclic_match_id
      t.string :betclic_event_id

      t.integer :sport_id

      t.string :team_a
      t.string :team_b

      t.string :name
      t.string :en_name
      t.string :fr_name

      t.datetime :start_at
      t.string :status
      t.timestamps
    end
    add_index :matches, [:opta_match_id]
    add_index :matches, [:sport_id]

    # Restructive competition
    drop_table :competitions
    create_table :competitions do |t|
      t.string :opta_competition_id
      t.string :name
      t.string :opta_area_id
      t.string :country_code
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :competitions, [:opta_competition_id]

    # Restructive Season
    drop_table :seasons
    create_table :seasons do |t|
      t.string :opta_season_id
      t.string :opta_competition_id
      t.string :name
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
    add_index :seasons, [:opta_season_id]
  end
end
