class RemoveNumberOfWeeksFromSites < ActiveRecord::Migration
  def up
    remove_column :sites, :numberOfWeeks
      end

  def down
    add_column :sites, :numberOfWeeks, :string
  end
end
