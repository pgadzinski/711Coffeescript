class AddNumberOfRowsToSites < ActiveRecord::Migration
  def change
    add_column :sites, :numberOfRows, :string

  end
end
