class AddSchedPixelValToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :schedPixelVal, :string

  end
end
