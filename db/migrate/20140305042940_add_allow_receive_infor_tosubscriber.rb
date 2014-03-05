class AddAllowReceiveInforTosubscriber < ActiveRecord::Migration
  def change
    add_column :subscribers, :receive_info_from_partners, :boolean, default: false
  end
end
