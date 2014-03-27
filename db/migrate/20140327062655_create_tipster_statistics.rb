class CreateTipsterStatistics < ActiveRecord::Migration
  def change
    create_table :tipster_statistics do |t|
      t.integer :tipster_id, null: false
      t.text :data, limit: 16777215
      t.datetime :updated_at
      t.index :tipster_id
    end
  end
end
