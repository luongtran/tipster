class AddMoreInformationToSubsciber < ActiveRecord::Migration
  def change
    add_column :subscribers, :nickname, :string, after: :last_name
    add_column :subscribers, :gender, :boolean, default: true, after: :gender
    add_column :subscribers, :receive_tip_methods, :string, after: :telephone
    add_column :subscribers, :created_by_omniauth, :boolean, default: false
  end
end
