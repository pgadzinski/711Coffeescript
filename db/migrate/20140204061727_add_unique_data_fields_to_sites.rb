class AddUniqueDataFieldsToSites < ActiveRecord::Migration
  def change
    add_column :sites, :uniqueDataFields, :string

  end
end
