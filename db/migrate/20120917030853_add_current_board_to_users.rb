class AddCurrentBoardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :currentBoard, :string

  end
end
