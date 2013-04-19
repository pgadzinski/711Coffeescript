class AddNumberOfWeeksToUsers < ActiveRecord::Migration
  def change
    add_column :users, :numberOfWeeks, :string

  end
end
