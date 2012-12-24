class AddDefaultJobLengthToSites < ActiveRecord::Migration
  def change
    add_column :sites, :defaultJobLength, :string

  end
end
