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

ActiveRecord::Schema[7.1].define(version: 2024_01_29_115954) do
  create_table "error_occurrences", force: :cascade do |t|
    t.integer "error_id", null: false
    t.text "backtrace"
    t.json "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["error_id"], name: "index_error_occurrences_on_error_id"
  end

  create_table "errors", force: :cascade do |t|
    t.string "exception_class", null: false
    t.string "message", null: false
    t.string "severity", null: false
    t.string "source"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exception_class", "message", "severity", "source"], name: "solid_error_uniqueness_index", unique: true
    t.index ["resolved_at"], name: "index_errors_on_resolved_at"
  end

  add_foreign_key "error_occurrences", "errors"
end
