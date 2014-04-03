class CleanMatchesTable < ActiveRecord::Migration
  def change
    remove_column :matches, :betclic_match_id
    remove_column :matches, :betclic_event_id
  end

  def self.down
    # Do nothing
  end
end
