class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :maxscheduler_id
      t.string :site_id
      t.string :name
      t.integer :position
      t.string :board_id

      t.timestamps
    end
  end
end
