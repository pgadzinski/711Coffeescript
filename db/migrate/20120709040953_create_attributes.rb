class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.string :name
      t.string :maxscheduler_id
      t.integer :importposition
      t.integer :listposition
      t.integer :scheduleposition

      t.timestamps
    end
  end
end
