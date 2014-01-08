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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140108214030) do

  create_table "sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "session_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id"

  create_table "universes", force: true do |t|
    t.string   "name"
    t.float    "entropy"
    t.integer  "light_years"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "universe_id"
    t.boolean  "dead"
    t.datetime "born_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["universe_id"], name: "index_users_on_universe_id"

end
