class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.integer :subscriber_id
      t.string :provider
      t.string :uid
      t.string :avatar_url
      t.timestamps
    end
    add_index :authorizations, :subscriber_id
    add_index :authorizations, :uid
  end
end
