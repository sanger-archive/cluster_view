# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100621093735) do

  create_table "bulk_upload_images", :force => true do |t|
    t.integer  "batch_id"
    t.integer  "bulk_upload_id"
    t.integer  "position"
    t.binary   "data_file",           :limit => 10485760
    t.binary   "data_thumbnail_file", :limit => 10485760
    t.string   "data_file_name"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.string   "data_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bulk_uploads", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.binary   "data_file",           :limit => 10485760
    t.binary   "data_thumbnail_file", :limit => 10485760
    t.string   "data_file_name"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.string   "data_content_type"
  end

  add_index "images", ["batch_id", "position"], :name => "position_within_batch_is_unique", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
