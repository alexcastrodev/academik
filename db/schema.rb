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

ActiveRecord::Schema[8.1].define(version: 2026_05_11_112129) do
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

  create_table "annotations", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "end_offset"
    t.text "note"
    t.integer "page"
    t.integer "paper_id", null: false
    t.text "selected_text"
    t.integer "start_offset"
    t.datetime "updated_at", null: false
    t.index ["paper_id"], name: "index_annotations_on_paper_id"
  end

  create_table "app_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["key"], name: "index_app_settings_on_key", unique: true
  end

  create_table "collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_collections_on_parent_id"
  end

  create_table "latex_documents", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "generation_type", default: 2, null: false
    t.bigint "sourceable_id"
    t.string "sourceable_type"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["sourceable_type", "sourceable_id"], name: "index_latex_documents_on_sourceable_type_and_sourceable_id"
  end

  create_table "paper_collections", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.datetime "created_at", null: false
    t.integer "paper_id", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_paper_collections_on_collection_id"
    t.index ["paper_id", "collection_id"], name: "index_paper_collections_on_paper_id_and_collection_id", unique: true
    t.index ["paper_id"], name: "index_paper_collections_on_paper_id"
  end

  create_table "paper_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "paper_id", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["paper_id", "tag_id"], name: "index_paper_tags_on_paper_id_and_tag_id", unique: true
    t.index ["paper_id"], name: "index_paper_tags_on_paper_id"
    t.index ["tag_id"], name: "index_paper_tags_on_tag_id"
  end

  create_table "papers", force: :cascade do |t|
    t.text "abstract"
    t.string "authors"
    t.datetime "created_at", null: false
    t.string "doi"
    t.text "extracted_text"
    t.string "journal"
    t.text "notes"
    t.integer "rating"
    t.integer "reading_status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["doi"], name: "index_papers_on_doi", unique: true, where: "doi IS NOT NULL"
  end

  create_table "summaries", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.string "model_used"
    t.integer "paper_id", null: false
    t.integer "status"
    t.integer "token_count"
    t.datetime "updated_at", null: false
    t.index ["paper_id"], name: "index_summaries_on_paper_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color", default: "#6366f1", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "annotations", "papers"
  add_foreign_key "paper_collections", "collections"
  add_foreign_key "paper_collections", "papers"
  add_foreign_key "paper_tags", "papers"
  add_foreign_key "paper_tags", "tags"
  add_foreign_key "summaries", "papers"
end
