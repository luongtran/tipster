class AddColumnToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions,:payment_status,:string
  end
end
