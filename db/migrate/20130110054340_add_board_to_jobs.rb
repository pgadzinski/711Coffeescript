class AddBoardToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :board, :string

  end
end
