class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :sport_id

      t.string :name
      t.string :en_name
      t.string :fr_name

      t.string :betclic_match_id
      t.string :betclic_event_id

      t.string :optasport_match_id

      t.datetime :start_at
      t.boolean :played
      t.timestamps
    end
  end
end
