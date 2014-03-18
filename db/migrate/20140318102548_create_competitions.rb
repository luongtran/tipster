class CreateCompetitions < ActiveRecord::Migration
  def change
    create_table :competitions do |t|
      t.integer :competition_id
      t.string :name
      t.integer :area_id
      t.boolean :active, default: true
    end
  end
end
