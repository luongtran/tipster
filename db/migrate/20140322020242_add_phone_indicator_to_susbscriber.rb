class AddPhoneIndicatorToSusbscriber < ActiveRecord::Migration
  def change
    add_column :subscribers, :phone_indicator, :string
  end
end
