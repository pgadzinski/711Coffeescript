class AddSchedHeightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :SchedHeight, :string

  end
end
