class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :maxscheduler_id
      t.string :site_id
      t.string :name
      t.string :user_id

      t.timestamps
    end
  end
end
