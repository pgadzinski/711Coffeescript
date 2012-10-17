class AddMaxschedulerIdFromUsers < ActiveRecord::Migration
  def change
    add_column :users, :maxscheduler_id, :string

  end
end
