class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :name
      t.string :season_id # id on optasport
      t.datetime :start_date
      t.datetime :end_date
      t.string :competition_id
      t.timestamps
    end
  end
end
