class AddSchedItemDelimiterToSites < ActiveRecord::Migration
  def change
    add_column :sites, :schedItemDelimiter, :string

  end
end
