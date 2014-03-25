class CreateSubscriptionTipsters < ActiveRecord::Migration
  def change
    create_table :subscription_tipsters do |t|
      t.integer :tipster_id
      t.integer :subscription_id
      t.boolean :active, :default => false
      t.boolean :is_primary, default: false
      t.integer :payment_id
      t.datetime :active_at
      t.datetime :expired_at

      t.timestamps
    end
    add_index :subscription_tipsters, :subscription_id
    add_index :subscription_tipsters, :tipster_id
    add_index :subscription_tipsters, :payment_id
  end
end
