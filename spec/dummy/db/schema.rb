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

ActiveRecord::Schema.define(version: 2019_04_10_022507) do

  create_table "achiever_achievements", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.integer "progress", default: 0, null: false
    t.integer "notified_progress", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_achiever_achievements_on_user_id_and_name", unique: true
  end

  create_table "achiever_scheduled_achievements", force: :cascade do |t|
    t.integer "achievement_id"
    t.integer "payload"
    t.datetime "due"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tags"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "age", default: 0
  end

end
