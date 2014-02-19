class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :subscription_id
      t.datetime :payment_date
      t.string :payer_first_name
      t.string :payer_last_name
      t.string :payer_email
      t.string :residence_country
      t.string :pending_reason
      t.string :mc_currency
      t.string :business_email
      t.string :payment_type
      t.string :payer_status
      t.boolean :test_ipn
      t.float :tax
      t.string :txn_id
      t.string :receiver_email
      t.string :payer_id
      t.string :receiver_id
      t.string :payment_status
      t.float :mc_gross
      t.timestamps
    end
  end
end
