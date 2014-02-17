class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :avatar_url
      t.timestamps
    end
    add_index :authorizations, :user_id
    add_index :authorizations, :uid
  end
end
