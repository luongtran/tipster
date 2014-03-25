class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.boolean :gender, default: true
      t.string :civility
      t.date :birthday
      t.string :address
      t.string :city
      t.string :country
      t.string :zip_code
      t.string :phone_indicator
      t.string :mobile_phone
      t.string :telephone
      t.string :favorite_beting_website
      t.string :know_website_from
      t.integer :secret_question
      t.string :answer_secret_question
      t.boolean :receive_info_from_partners, default: false
      t.string :receive_tip_methods
      t.boolean :created_by_omniauth, default: false
      t.timestamps
    end
  end
end
