class CreateSubscriptionsTipsters < ActiveRecord::Migration
  def change
    # FIXME, the table name should be subscribers_tipsters (missing 's')
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
