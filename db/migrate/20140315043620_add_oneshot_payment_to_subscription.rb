class AddOneshotPaymentToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :is_one_shoot, :boolean, default: false
  end
end
