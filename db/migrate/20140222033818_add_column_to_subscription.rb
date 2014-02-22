class AddColumnToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :active, :boolean
    add_column :subscriptions, :active_date, :datetime
    add_column :subscriptions, :expired_date, :datetime
  end
end
