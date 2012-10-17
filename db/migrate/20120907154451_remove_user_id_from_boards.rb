class RemoveUserIdFromBoards < ActiveRecord::Migration
  def up
    remove_column :boards, :user_id
      end

  def down
    add_column :boards, :user_id, :string
  end
end
