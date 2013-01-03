class RemoveEndFromOperationhours < ActiveRecord::Migration
  def up
    remove_column :operationhours, :end
      end

  def down
    add_column :operationhours, :end, :string
  end
end
