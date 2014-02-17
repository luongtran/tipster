class CreateSubscriberTipsters < ActiveRecord::Migration
  def change
    # FIXME, the table name should be subscribers_tipsters (missing 's')
    create_table :subscriber_tipsters do |t|
      t.integer :tipster_id
      t.integer :subscription_id
      t.timestamps
    end
  end
end
