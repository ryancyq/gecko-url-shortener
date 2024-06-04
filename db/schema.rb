# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_04_065622) do
  create_table "short_url_events", force: :cascade do |t|
    t.string "user_agent"
    t.string "ip_address", null: false
    t.string "path", null: false
    t.string "method", null: false
    t.integer "short_url_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["short_url_id"], name: "index_short_url_events_on_short_url_id"
  end

  create_table "short_urls", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "target_url_id"
    t.datetime "created_at"
    t.index ["slug"], name: "index_short_urls_on_slug", unique: true
  end

  create_table "target_urls", force: :cascade do |t|
    t.string "external_url", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_url"], name: "index_target_urls_on_external_url", unique: true
  end

  add_foreign_key "short_url_events", "short_urls"
  add_foreign_key "short_urls", "target_urls"
end
