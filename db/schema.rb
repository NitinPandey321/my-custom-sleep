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

ActiveRecord::Schema[8.0].define(version: 2025_09_21_121327) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "role", null: false
    t.integer "action", null: false
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.text "details"
    t.inet "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "avg_response_time", default: 0, null: false
  end

  create_table "daily_reflections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "mood"
    t.text "note"
    t.date "reflection_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_daily_reflections_on_user_id"
  end

  create_table "email_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "email_type"
    t.string "subject"
    t.string "status"
    t.datetime "sent_at"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_email_logs_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "conversation_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "details", null: false
    t.integer "wellness_pillar", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "duration"
    t.integer "reminder_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "resubmission_reason"
    t.datetime "client_submitted_at"
    t.index ["user_id"], name: "index_plans_on_user_id"
  end

  create_table "sleep_metrics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "baseline_score"
    t.float "current_avg_score"
    t.float "improvement"
    t.datetime "calculated_at"
    t.date "baseline_start"
    t.date "baseline_end"
    t.date "current_start"
    t.date "current_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sleep_metrics_on_user_id"
  end

  create_table "sleep_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.integer "score"
    t.jsonb "raw_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.string "profile_image"
    t.boolean "onboarding_completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coach_id"
    t.integer "status", default: 0, null: false
    t.string "country_code"
    t.string "mobile_number"
    t.string "reset_password_otp_digest"
    t.datetime "reset_password_sent_at"
    t.integer "reset_password_attempts", default: 0
    t.boolean "deactivated", default: false
    t.integer "avg_response_time", default: 0, null: false
    t.integer "plan_streak", default: 0, null: false
    t.integer "longest_plan_streak", default: 0, null: false
    t.datetime "last_seen_at"
    t.integer "rest_level", default: 0, null: false
    t.integer "on_time_weeks", default: 0, null: false
    t.integer "missed_weeks", default: 0, null: false
    t.string "oura_access_token"
    t.string "oura_refresh_token"
    t.datetime "oura_expires_at"
    t.string "phone_e164"
    t.string "phone_country_iso2"
    t.string "unverified_email"
    t.string "email_verification_token"
    t.string "gender"
    t.string "preferred_coach_gender"
    t.index ["coach_id"], name: "index_users_on_coach_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_e164"], name: "index_users_on_phone_e164"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "daily_reflections", "users"
  add_foreign_key "email_logs", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "plans", "users"
  add_foreign_key "sleep_metrics", "users"
  add_foreign_key "users", "users", column: "coach_id"
end
