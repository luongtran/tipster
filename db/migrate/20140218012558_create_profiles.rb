class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id, :null => false
      t.string :civility
      t.date :birthday
      t.string :address
      t.string :city
      t.string :country
      t.string :zip_code
      t.string :mobile_phone
      t.string :telephone
      t.string :favorite_betting_website
      t.string :know_website_from
      t.integer :secret_question
      t.string :answer_secret_question

      t.boolean :received_information_from_partners, :default => false
      t.timestamps
    end
    add_index :profiles, :user_id

    # Move birthday to profile
    remove_column :users, :birthday if column_exists? :users, :birthday
  end
end
