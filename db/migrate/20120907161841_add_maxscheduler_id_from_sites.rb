class AddMaxschedulerIdFromSites < ActiveRecord::Migration
  def change
    add_column :sites, :maxscheduler_id, :string

  end
end
