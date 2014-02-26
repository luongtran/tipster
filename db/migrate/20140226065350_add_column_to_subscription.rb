class AddColumnToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions,:using_coupon,:boolean , :default => false
  end
end
