class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|

      t.timestamps
    end
    create_table :carts_tipsters do |t|
      t.belongs_to :cart
      t.belongs_to :tipster
    end
  end
end
