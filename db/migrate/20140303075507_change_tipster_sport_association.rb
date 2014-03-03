class ChangeTipsterSportAssociation < ActiveRecord::Migration
  def change
    #remove_column 'users', :sport_id
    create_join_table :sports, :users do |t|
      t.index [:sport_id, :user_id]
    end
  end
end
