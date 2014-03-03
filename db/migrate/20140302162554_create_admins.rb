class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :full_name
      t.timestamps
    end
  end
end
