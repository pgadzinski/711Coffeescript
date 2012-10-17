class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :maxscheduler_id
      t.string :site_id
      t.string :user_id
      t.string :resource_id
      t.string :schedDate
      t.string :schedTime
      t.string :attr1
      t.string :attr2
      t.string :attr3
      t.string :attr4
      t.string :attr5
      t.string :attr6
      t.string :attr7
      t.string :attr8
      t.string :attr9
      t.string :attr10
      t.string :attr11
      t.string :attr12
      t.string :attr13
      t.string :attr14
      t.string :attr15
      t.string :attr16
      t.string :attr17
      t.string :attr18
      t.string :attr19
      t.string :attr20
      t.string :attr21
      t.string :attr22
      t.string :attr23
      t.string :attr24
      t.string :attr25
      t.string :attr26
      t.string :attr27
      t.string :attr28
      t.string :attr29
      t.string :attr30

      t.timestamps
    end
  end
end
