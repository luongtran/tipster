class AddDescriptionToTipster < ActiveRecord::Migration
  def change
    add_column :tipsters, :description, :text
  end
end
