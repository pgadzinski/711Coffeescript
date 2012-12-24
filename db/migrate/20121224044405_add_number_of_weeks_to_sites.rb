class AddNumberOfWeeksToSites < ActiveRecord::Migration
  def change
    add_column :sites, :numberOfWeeks, :string

  end
end
