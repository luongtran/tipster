class AddMissingIndexs < ActiveRecord::Migration
  def change
    add_index :payments, :subscription_id
    add_index :payments, :coupon_code_id
    add_index :subscriptions, :user_id
    add_index :subscriptions, :plan_id
  end
end
