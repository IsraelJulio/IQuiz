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

ActiveRecord::Schema[7.2].define(version: 2024_01_01_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.string "icon", default: "🏆", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_achievements_on_key", unique: true
  end

  create_table "card_attempts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "card_id", null: false
    t.bigint "game_session_id", null: false
    t.string "direction", null: false
    t.boolean "correct", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_attempts_on_card_id"
    t.index ["game_session_id"], name: "index_card_attempts_on_game_session_id"
    t.index ["user_id", "card_id", "direction"], name: "index_card_attempts_on_user_id_and_card_id_and_direction"
    t.index ["user_id"], name: "index_card_attempts_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "deck_id", null: false
    t.text "front", null: false
    t.text "back", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_cards_on_deck_id"
  end

  create_table "decks", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_decks_on_deleted_at"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "deck_id"
    t.string "deck_name"
    t.string "game_mode", null: false
    t.string "direction", null: false
    t.string "status", default: "in_progress", null: false
    t.jsonb "card_order", default: [], null: false
    t.integer "current_card_index", default: 0, null: false
    t.decimal "total_points", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "cards_total", default: 0, null: false
    t.integer "cards_correct", default: 0, null: false
    t.integer "max_streak", default: 0, null: false
    t.integer "current_streak", default: 0, null: false
    t.boolean "anti_grind", default: false, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_game_sessions_on_deck_id"
    t.index ["started_at"], name: "index_game_sessions_on_started_at"
    t.index ["status"], name: "index_game_sessions_on_status"
    t.index ["user_id"], name: "index_game_sessions_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "deck_id"
    t.decimal "target_percentage", precision: 5, scale: 2, null: false
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_goals_on_deck_id"
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "user_achievements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "achievement_id", null: false
    t.datetime "unlocked_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_israel", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "card_attempts", "cards"
  add_foreign_key "card_attempts", "game_sessions"
  add_foreign_key "card_attempts", "users"
  add_foreign_key "cards", "decks"
  add_foreign_key "game_sessions", "decks"
  add_foreign_key "game_sessions", "users"
  add_foreign_key "goals", "decks"
  add_foreign_key "goals", "users"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "users"
end
