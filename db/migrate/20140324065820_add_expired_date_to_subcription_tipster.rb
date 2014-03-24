class AddExpiredDateToSubcriptionTipster < ActiveRecord::Migration
  def change
    add_column :subscription_tipsters,:active_at,:datetime
    add_column :subscription_tipsters ,:expired_at,:datetime
  end
end
