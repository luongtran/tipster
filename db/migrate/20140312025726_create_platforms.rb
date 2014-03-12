class CreatePlatforms < ActiveRecord::Migration
  def change
    create_table :platforms do |t|
      t.string :code, null: false
      t.string :name, null: false
    end
  end
end
