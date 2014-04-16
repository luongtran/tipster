class CreateBookmarkerMatches < ActiveRecord::Migration
  def change
    create_table :bookmarker_matches do |t|
      t.integer :match_id, null: false # ID on bookmarker
      t.string :bookmarker_code, null: false
      t.string :sport_code # Sport code in local db

      t.string :name, null: false # Name on bookmarker
      t.string :team_a_name
      t.string :team_b_name

      t.integer :competition_id # ID on bookmarker
      t.string :competition_name # Name on bookmarker

      t.datetime :start_at, null: false
      t.datetime :updated_at

      #t.index :bookmarker_code
      #t.index :sport_code
    end
  end
end