class AddColumnWidthToAttributes < ActiveRecord::Migration
  def change
    add_column :attributes, :columnWidth, :integer

  end
end
