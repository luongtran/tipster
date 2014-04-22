class CreateManualMatches < ActiveRecord::Migration
  def change
    create_table :manual_matches do |t|
      t.string :name
      t.string :sport_code
      t.datetime :created_at
    end
  end
end
