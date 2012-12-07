class RemoveMaxschedulerIdFromSites < ActiveRecord::Migration
  def up
    remove_column :sites, :Maxscheduler_id
      end

  def down
    add_column :sites, :Maxscheduler_id, :string
  end
end
