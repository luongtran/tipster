class CreateSubscriptionTipsters < ActiveRecord::Migration
  def change
    create_table :subscription_tipsters do |t|
      t.integer :tipster_id
      t.integer :subscription_id
      t.boolean :active, :default => false
      t.timestamps
    end
    add_index :subscription_tipsters, :subscription_id
    add_index :subscription_tipsters, :tipster_id
  end
end
