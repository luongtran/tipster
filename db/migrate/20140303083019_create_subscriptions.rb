class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :subscriber_id
      t.integer :plan_id
      t.boolean :using_coupon, default: false
      t.boolean :active, default: false

      t.boolean :is_one_shoot, default: false
      t.datetime :active_at
      t.datetime :expired_at
      t.string :payment_status
      t.timestamps
    end
    add_index :subscriptions, :subscriber_id
    add_index :subscriptions, :plan_id
  end
end
