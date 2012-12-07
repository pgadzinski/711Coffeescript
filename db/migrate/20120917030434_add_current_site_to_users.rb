class AddCurrentSiteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :currentSite, :string

  end
end
