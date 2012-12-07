class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :FirstName
      t.string :LastName
      t.string :email
      t.string :color
      t.integer :rowHeight

      t.timestamps
    end
  end
end
