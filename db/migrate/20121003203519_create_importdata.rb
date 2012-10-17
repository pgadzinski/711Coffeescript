class CreateImportdata < ActiveRecord::Migration
  def change
    create_table :importdata do |t|
      t.string :maxscheduler_id
      t.string :site_id
      t.string :user_id
      t.text :data

      t.timestamps
    end
  end
end
