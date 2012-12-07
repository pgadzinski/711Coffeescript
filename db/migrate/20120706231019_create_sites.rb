class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.string :Maxscheduler_id
      t.string :rowTimeIncrement
      t.string :dateTimeColumnWidth

      t.timestamps
    end
  end
end
