class CreateOperationhours < ActiveRecord::Migration
  def change
    create_table :operationhours do |t|
      t.string :maxscheduler_id
      t.string :site_id
      t.string :dayOfTheWeek
      t.time :start
      t.time :end

      t.timestamps
    end
  end
end
