class RemoveSchedTimeFromJobs < ActiveRecord::Migration
  def up
    remove_column :jobs, :schedTime
      end

  def down
    add_column :jobs, :schedTime, :string
  end
end
