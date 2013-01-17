class AddBoardIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :board_id, :string

  end
end
