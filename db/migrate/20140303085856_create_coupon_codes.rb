class CreateCouponCodes < ActiveRecord::Migration
  def change
    create_table :coupon_codes do |t|
      t.integer :subscriber_id
      t.string :code, null: false
      t.string :source
      t.boolean :is_used, default: false
      t.datetime :used_at
      t.datetime :created_at, null: false
    end
    add_index :coupon_codes, :subscriber_id
  end
end
