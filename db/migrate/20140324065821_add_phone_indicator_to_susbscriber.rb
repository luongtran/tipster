class AddPhoneIndicatorToSusbscriber < ActiveRecord::Migration
  def change
    add_column :subscribers, :phone_indicator, :string unless column_exists?(:subscribers,:phone_indicator)
  end
end
