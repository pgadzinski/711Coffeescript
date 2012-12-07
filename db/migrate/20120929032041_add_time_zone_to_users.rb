class AddTimeZoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :timeZone, :string

  end
end
