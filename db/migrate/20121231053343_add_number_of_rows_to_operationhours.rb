class AddNumberOfRowsToOperationhours < ActiveRecord::Migration
  def change
    add_column :operationhours, :numberOfRows, :string

  end
end
