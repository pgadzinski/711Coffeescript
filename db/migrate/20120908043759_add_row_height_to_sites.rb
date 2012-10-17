class AddRowHeightToSites < ActiveRecord::Migration
  def change
    add_column :sites, :rowHeight, :string

  end
end
