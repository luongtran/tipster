class CreateOptaCompetitions < ActiveRecord::Migration
  def change
    create_table :opta_competitions do |t|
      t.integer :opta_area_id
      t.integer :opta_competition_id
      t.string :sport_code
      t.string :name
      t.boolean :active, default: true
      t.datetime :updated_at

      # Indexing
      t.index :opta_competition_id
      t.index :sport_code
    end
  end
end
