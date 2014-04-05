class CreateSportTipsterJoinTable < ActiveRecord::Migration
  def change
    create_table :sports_tipsters do |t|
      t.string :sport_code
      t.integer :tipster_id
      t.index [:sport_code, :tipster_id]
    end
  end
end
