class CreateBookmarkers < ActiveRecord::Migration
  def change
    create_table :bookmarkers do |t|
      t.string :code, null: false
      t.string :name, null: false
    end
  end
end
