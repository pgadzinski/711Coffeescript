class RemoveNumberOfRowsFromSites < ActiveRecord::Migration
  def up
    remove_column :sites, :numberOfRows
      end

  def down
    add_column :sites, :numberOfRows, :string
  end
end
