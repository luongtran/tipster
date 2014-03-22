class AddSportToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :sport_id, :integer
  end
end
