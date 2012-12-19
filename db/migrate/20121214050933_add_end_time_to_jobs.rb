class AddEndTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :endTime, :string

  end
end
