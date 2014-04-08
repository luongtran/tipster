class AddRejectReasonToTip < ActiveRecord::Migration
  def change
    add_column :tips, :reject_reason, :text
  end
end
