class CreateTipJournals < ActiveRecord::Migration
  def change
    create_table :tip_journals do |t|
      t.integer :tip_id
      t.integer :author_id
      t.string :author_type
      t.string :event
      t.datetime :created_at
    end
  end
end
