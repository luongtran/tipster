class AddColumnToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :adding_price, :float
  end
end
