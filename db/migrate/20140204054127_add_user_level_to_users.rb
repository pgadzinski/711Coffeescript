class AddUserLevelToUsers < ActiveRecord::Migration
  def change
    add_column :users, :userLevel, :string

  end
end
