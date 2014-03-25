class CreateTipsters < ActiveRecord::Migration
  def change
    create_table :tipsters do |t|
      t.string :display_name
      t.string :full_name
      t.string :avatar
      t.integer :status
      t.boolean :active, default: true
      t.text  :description
      t.timestamps
    end
  end
end
