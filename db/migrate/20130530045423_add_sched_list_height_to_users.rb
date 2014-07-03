class AddSchedListHeightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :SchedListHeight, :string

  end
end
