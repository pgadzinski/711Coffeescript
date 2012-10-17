class AddSchedDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :schedStartDate, :string

  end
end
