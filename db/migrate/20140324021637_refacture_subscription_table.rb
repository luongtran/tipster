class RefactureSubscriptionTable < ActiveRecord::Migration
  def change
    add_column :subscription_tipsters,:is_primary,:boolean, default: false
    add_column :subscription_tipsters,:payment_id,:integer
  end
end