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

ActiveRecord::Schema.define(:version => 20100618160707) do

  create_table "bulk_upload_images", :force => true do |t|
    t.integer  "batch_id"
    t.integer  "bulk_upload_id"
    t.integer  "position"
    t.binary   "data_file",           :limit => 16777215
    t.binary   "data_thumbnail_file", :limit => 16777215
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
    t.binary   "data_file",           :limit => 16777215
    t.binary   "data_thumbnail_file", :limit => 16777215
    t.string   "data_file_name"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.string   "data_content_type"
  end

  create_table "legacy_images", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.string   "batch_id"
    t.string   "sample_name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.integer  "lane"
    t.boolean  "passed"
    t.integer  "position"
    t.integer  "sample_id"
    t.boolean  "batch"
    t.boolean  "migrated",     :default => false
  end

  create_table "legacy_sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  create_table "legacy_users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "api_key"
  end

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
