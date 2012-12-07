class AddSchedDateTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :schedDateTime, :string

  end
end
