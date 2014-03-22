class AddColumnDefinePrimaryTipsterToSubscription < ActiveRecord::Migration
  def change
    add_column :subscription_tipsters,:type,:string
  end
end
