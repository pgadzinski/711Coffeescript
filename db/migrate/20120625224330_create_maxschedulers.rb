class CreateMaxschedulers < ActiveRecord::Migration
  def change
    create_table :maxschedulers do |t|
      t.string :name
      t.string :paying

      t.timestamps
    end
  end
end
