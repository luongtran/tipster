class CreateOptaTours < ActiveRecord::Migration
  def change
    create_table :opta_tours do |t|
      t.integer :opta_tour_id
      t.string :name
      t.datetime :update_at
    end
  end
end
