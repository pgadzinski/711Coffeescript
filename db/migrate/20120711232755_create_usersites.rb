class CreateUsersites < ActiveRecord::Migration
  def change
    create_table :usersites do |t|
      t.string :maxscheduler_id
      t.string :site_id
      t.string :user_id

      t.timestamps
    end
  end
end
