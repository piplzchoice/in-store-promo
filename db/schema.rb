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

ActiveRecord::Schema.define(version: 20141130130355) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "available_dates", force: true do |t|
    t.integer  "brand_ambassador_id"
    t.date     "availablty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "am",                  default: false
    t.boolean  "pm",                  default: false
  end

  create_table "brand_ambassadors", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.integer  "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "mileage"
    t.decimal  "rate",       precision: 8, scale: 2
    t.boolean  "is_active",                          default: true
  end

  create_table "clients", force: true do |t|
    t.integer  "user_id"
    t.string   "company_name"
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "street_one"
    t.string   "street_two"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "country"
    t.string   "billing_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "is_active",                            default: true
    t.decimal  "rate",         precision: 8, scale: 2
  end

  create_table "default_values", force: true do |t|
    t.decimal  "rate_project",      precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "traffic"
    t.string   "sample_product"
    t.integer  "service_hours_est"
    t.integer  "send_unrespond"
    t.decimal  "co_op_price",       precision: 8, scale: 2
  end

  create_table "email_templates", force: true do |t|
    t.string   "name"
    t.string   "subject"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: true do |t|
    t.integer  "client_id"
    t.string   "service_ids"
    t.text     "line_items"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rate_total_all",     precision: 8, scale: 2
    t.decimal  "expsense_total_all", precision: 8, scale: 2
    t.decimal  "travel_total_all",   precision: 8, scale: 2
    t.decimal  "grand_total_all",    precision: 8, scale: 2
    t.integer  "status",                                     default: 0
    t.decimal  "grand_total",        precision: 8, scale: 2
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "is_active",  default: true
  end

  create_table "projects", force: true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "name"
    t.string   "descriptions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_at"
    t.date     "end_at"
    t.decimal  "rate",         precision: 8, scale: 2
    t.boolean  "is_active",                            default: true
    t.integer  "status",                               default: 1
  end

  create_table "redactor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], name: "idx_redactor_assetable", using: :btree
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_redactor_assetable_type", using: :btree

  create_table "reports", force: true do |t|
    t.integer  "service_id"
    t.string   "demo_in_store"
    t.string   "weather"
    t.string   "traffic"
    t.string   "busiest_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "products"
    t.string   "product_one"
    t.integer  "product_one_beginning"
    t.integer  "product_one_end"
    t.integer  "product_one_sold"
    t.string   "product_two"
    t.integer  "product_two_beginning"
    t.integer  "product_two_end"
    t.integer  "product_two_sold"
    t.string   "product_three"
    t.integer  "product_three_beginning"
    t.integer  "product_three_end"
    t.integer  "product_three_sold"
    t.string   "product_four"
    t.integer  "product_four_beginning"
    t.integer  "product_four_end"
    t.integer  "product_four_sold"
    t.string   "sample_product"
    t.string   "est_customer_touched"
    t.string   "est_sample_given"
    t.string   "expense_one_img"
    t.string   "expense_two_img"
    t.text     "customer_comments"
    t.text     "ba_comments"
    t.decimal  "product_one_price",       precision: 8, scale: 2
    t.decimal  "product_two_price",       precision: 8, scale: 2
    t.decimal  "product_three_price",     precision: 8, scale: 2
    t.decimal  "product_four_price",      precision: 8, scale: 2
    t.integer  "product_one_sample"
    t.integer  "product_two_sample"
    t.integer  "product_three_sample"
    t.integer  "product_four_sample"
    t.decimal  "expense_one",             precision: 8, scale: 2, default: 0.0
    t.decimal  "expense_two",             precision: 8, scale: 2, default: 0.0
    t.integer  "product_five_sample"
    t.decimal  "product_five_price",      precision: 8, scale: 2
    t.string   "product_five"
    t.integer  "product_five_beginning"
    t.integer  "product_five_end"
    t.integer  "product_five_sold"
    t.integer  "product_six_sample"
    t.decimal  "product_six_price",       precision: 8, scale: 2
    t.string   "product_six"
    t.integer  "product_six_beginning"
    t.integer  "product_six_end"
    t.integer  "product_six_sold"
    t.string   "table_image_one_img"
    t.string   "table_image_two_img"
    t.boolean  "is_active",                                       default: true
    t.decimal  "travel_expense",          precision: 8, scale: 2
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "services", force: true do |t|
    t.integer  "project_id"
    t.integer  "location_id"
    t.integer  "brand_ambassador_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "details"
    t.integer  "status",              default: 1
    t.string   "token"
    t.boolean  "is_active",           default: true
    t.integer  "client_id"
    t.integer  "co_op_client_id"
  end

  create_table "statements", force: true do |t|
    t.integer  "brand_ambassador_id"
    t.string   "file"
    t.string   "state_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "services_ids"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",              default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
