class AddDeskSchedWidthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :DeskSchedWidth, :string

  end
end
