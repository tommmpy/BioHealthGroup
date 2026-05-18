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

ActiveRecord::Schema[8.2].define(version: 2026_05_18_014906) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.text "audited_changes"
    t.string "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "branches", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.boolean "enabled", default: true
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "chat_room_participants", force: :cascade do |t|
    t.bigint "chat_room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["chat_room_id", "user_id"], name: "index_chat_room_participants_on_chat_room_id_and_user_id", unique: true
    t.index ["chat_room_id"], name: "index_chat_room_participants_on_chat_room_id"
    t.index ["user_id"], name: "index_chat_room_participants_on_user_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.integer "assigned_to_id"
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", null: false
    t.string "kind", default: "support", null: false
    t.datetime "reopen_requested_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_chat_rooms_on_assigned_to_id"
    t.index ["kind"], name: "index_chat_rooms_on_kind"
  end

  create_table "estudios", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.integer "cantidad_productos"
    t.datetime "created_at", null: false
    t.integer "estado"
    t.datetime "fecha_estudio"
    t.integer "medico_id"
    t.string "metar_paciente"
    t.string "nombre_completo"
    t.json "tipo_producto"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["branch_id"], name: "index_estudios_on_branch_id"
    t.index ["user_id"], name: "index_estudios_on_user_id"
  end

  create_table "hero_slides", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "cta_link"
    t.string "cta_text"
    t.integer "sort_order"
    t.string "subtitle"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_room_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.boolean "read", default: false, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read"], name: "index_notifications_on_user_id_and_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "process_steps", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.integer "step_number"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.jsonb "activity_log", default: []
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "last_url"
    t.datetime "terminated_at"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.string "user_name"
    t.integer "user_status", default: 0, null: false
    t.index ["terminated_at"], name: "index_sessions_on_terminated_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "testimonials", force: :cascade do |t|
    t.boolean "active"
    t.string "author_name"
    t.string "author_role"
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "sort_order"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.date "birthday"
    t.bigint "branch_id", null: false
    t.string "ci"
    t.string "contacto_root"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.datetime "last_active_at"
    t.string "last_name"
    t.string "password_digest", null: false
    t.string "phone_number"
    t.integer "role", default: 0
    t.integer "status", default: 3, null: false
    t.datetime "updated_at", null: false
    t.integer "user_type"
    t.index ["branch_id"], name: "index_users_on_branch_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_room_participants", "chat_rooms"
  add_foreign_key "chat_room_participants", "users"
  add_foreign_key "chat_rooms", "users", column: "assigned_to_id"
  add_foreign_key "estudios", "branches"
  add_foreign_key "estudios", "users"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "branches"
end
