class AddColumnToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions,:is_free,:boolean, default: false
  end
end
