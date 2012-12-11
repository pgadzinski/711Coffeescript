class CreateOperationhours < ActiveRecord::Migration
  def change
    create_table :operationhours do |t|
      t.string :maxscheduler_id
      t.string :site_id
      t.string :dayOfTheWeek
      t.string :start
      t.string :end

      t.timestamps
    end
  end
end
