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

ActiveRecord::Schema[8.1].define(version: 2026_10_28_212137) do
  create_table "list_items", force: :cascade do |t|
    t.integer "profile_id", null: false
    t.integer "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_list_items_on_movie_id"
    t.index ["profile_id", "movie_id"], name: "index_list_items_on_profile_id_and_movie_id", unique: true
    t.index ["profile_id"], name: "index_list_items_on_profile_id"
  end

  create_table "movies", force: :cascade do |t|
    t.integer "tmdb_id", null: false
    t.string "title", null: false
    t.string "poster_path"
    t.string "backdrop_path"
    t.date "release_date"
    t.text "overview"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "#e50914", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "profile_id", null: false
    t.integer "movie_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_reviews_on_movie_id"
    t.index ["profile_id", "movie_id"], name: "index_reviews_on_profile_id_and_movie_id", unique: true
    t.index ["profile_id"], name: "index_reviews_on_profile_id"
  end

  add_foreign_key "list_items", "movies"
  add_foreign_key "list_items", "profiles"
  add_foreign_key "reviews", "movies"
  add_foreign_key "reviews", "profiles"
end
