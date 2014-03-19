class AddMoreColumnsToCompetition < ActiveRecord::Migration
  def change
    add_column :matches, :competition_id, :string
    add_column :competitions, :country_code, :string
  end
end
