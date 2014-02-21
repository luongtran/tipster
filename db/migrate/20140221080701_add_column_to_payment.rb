class AddColumnToPayment < ActiveRecord::Migration
  def change
    add_column :payments,:coupon_code_id,:integer
  end
end
