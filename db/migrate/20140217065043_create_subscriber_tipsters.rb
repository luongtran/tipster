class CreateSubscriberTipsters < ActiveRecord::Migration
  def change
    create_table :subscriber_tipsters do |t|
      t.integer :tipster_id
      t.integer :subscription_id
      t.timestamps
    end
  end
end
