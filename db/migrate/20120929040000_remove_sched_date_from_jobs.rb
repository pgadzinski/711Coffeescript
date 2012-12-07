class RemoveSchedDateFromJobs < ActiveRecord::Migration
  def up
    remove_column :jobs, :schedDate
      end

  def down
    add_column :jobs, :schedDate, :string
  end
end
