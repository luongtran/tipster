class AddPaykeyToPayment < ActiveRecord::Migration
  def change
    add_column :payments,:paykey,:string
    add_column :payments,:amount,:float
    add_column :payments,:paid_for,:string
    add_column :payments,:tipster_ids,:string
    add_column :payments,:enable_history,:boolean ,default:  false
    add_column :payments,:is_recurring,:boolean ,default:  false
  end
end
