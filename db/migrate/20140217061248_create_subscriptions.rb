class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :plan_id
      t.boolean :active, :default => false
      t.datetime :active_date
      t.datetime :expired_date
      t.timestamps
    end
  end
end
