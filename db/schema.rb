# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130111032329) do

  create_table "attributes", :force => true do |t|
    t.string   "name"
    t.string   "maxscheduler_id"
    t.integer  "importposition"
    t.integer  "listposition"
    t.integer  "scheduleposition"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "columnWidth"
  end

  create_table "boards", :force => true do |t|
    t.string   "maxscheduler_id"
    t.string   "site_id"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "importdata", :force => true do |t|
    t.string   "maxscheduler_id"
    t.string   "site_id"
    t.string   "user_id"
    t.text     "data"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "jobs", :force => true do |t|
    t.string   "maxscheduler_id"
    t.string   "site_id"
    t.string   "user_id"
    t.string   "resource_id"
    t.string   "attr1"
    t.string   "attr2"
    t.string   "attr3"
    t.string   "attr4"
    t.string   "attr5"
    t.string   "attr6"
    t.string   "attr7"
    t.string   "attr8"
    t.string   "attr9"
    t.string   "attr10"
    t.string   "attr11"
    t.string   "attr12"
    t.string   "attr13"
    t.string   "attr14"
    t.string   "attr15"
    t.string   "attr16"
    t.string   "attr17"
    t.string   "attr18"
    t.string   "attr19"
    t.string   "attr20"
    t.string   "attr21"
    t.string   "attr22"
    t.string   "attr23"
    t.string   "attr24"
    t.string   "attr25"
    t.string   "attr26"
    t.string   "attr27"
    t.string   "attr28"
    t.string   "attr29"
    t.string   "attr30"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "schedDateTime"
    t.string   "schedPixelVal"
    t.string   "endTime"
    t.string   "board_id"
  end

  create_table "maxschedulers", :force => true do |t|
    t.string   "name"
    t.string   "paying"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "operationhours", :force => true do |t|
    t.string   "maxscheduler_id"
    t.string   "site_id"
    t.string   "dayOfTheWeek"
    t.string   "start"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "numberOfRows"
  end

  create_table "resources", :force => true do |t|
    t.string   "maxscheduler_id"
    t.string   "site_id"
    t.string   "name"
    t.integer  "position"
    t.string   "board_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "rowTimeIncrement"
    t.string   "dateTimeColumnWidth"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "maxscheduler_id"
    t.string   "rowHeight"
    t.string   "defaultJobLength"
    t.string   "numberOfWeeks"
  end

  create_table "users", :force => true do |t|
    t.string   "FirstName"
    t.string   "LastName"
    t.string   "email"
    t.string   "color"
    t.integer  "rowHeight"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
    t.string   "maxscheduler_id"
    t.string   "currentSite"
    t.string   "currentBoard"
    t.string   "schedStartDate"
    t.string   "timeZone"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "usersites", :force => true do |t|
    t.string   "maxscheduler_id"
    t.string   "site_id"
    t.string   "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
