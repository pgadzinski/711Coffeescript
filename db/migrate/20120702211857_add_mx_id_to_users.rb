class AddMxIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :Maxscheduler_id, :string

  end
end
