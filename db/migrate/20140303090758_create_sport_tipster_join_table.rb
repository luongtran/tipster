class CreateSportTipsterJoinTable < ActiveRecord::Migration
  def change
    create_join_table :sports, :tipsters do |t|
      t.index [:sport_id, :tipster_id]
    end
  end
end
