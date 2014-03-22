class FixAddingpriceColumn < ActiveRecord::Migration
  def change
    unless column_exists? :plans, :adding_price
      add_column :plans, :adding_price, :float
    end
  end
end
