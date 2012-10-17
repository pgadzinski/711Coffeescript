class RemoveMaxschedulerIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :Maxscheduler_id
      end

  def down
    add_column :users, :Maxscheduler_id, :string
  end
end
