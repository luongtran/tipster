class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.integer :amount, :default => 1
      t.string :currency
      t.string :token
      t.string :transaction_id
      t.string :payer_id
      t.boolean :completed, :default => false
      t.boolean :canceled, :default => false
      t.integer :payment_type
      t.datetime :created_at
      t.datetime :completed_at
    end
    add_index :invoices, :user_id
  end
end
