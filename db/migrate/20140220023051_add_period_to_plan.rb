class AddPeriodToPlan < ActiveRecord::Migration
  def change
    add_column :plans,:period,:integer
  end
end
