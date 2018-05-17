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

ActiveRecord::Schema.define(version: 20180515231510) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "name"
    t.float "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "review_employees", force: :cascade do |t|
    t.bigint "review_id"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_review_employees_on_employee_id"
    t.index ["review_id"], name: "index_review_employees_on_review_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "date"
    t.float "rating"
    t.string "title"
    t.string "user"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
  end

  add_foreign_key "review_employees", "employees"
  add_foreign_key "review_employees", "reviews"
end
