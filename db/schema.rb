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

ActiveRecord::Schema.define(version: 20140226090823) do

  create_table "authorizations", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["uid"], name: "index_authorizations_on_uid"
  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id"

  create_table "coupon_codes", force: true do |t|
    t.integer  "user_id"
    t.string   "code",                       null: false
    t.string   "source"
    t.boolean  "is_used",    default: false
    t.datetime "used_at"
    t.datetime "created_at",                 null: false
  end

  add_index "coupon_codes", ["user_id"], name: "index_coupon_codes_on_user_id"

  create_table "invoices", force: true do |t|
    t.integer  "user_id"
    t.integer  "amount",         default: 1
    t.string   "currency"
    t.string   "token"
    t.string   "transaction_id"
    t.string   "payer_id"
    t.boolean  "completed",      default: false
    t.boolean  "canceled",       default: false
    t.integer  "payment_type"
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  add_index "invoices", ["user_id"], name: "index_invoices_on_user_id"

  create_table "payments", force: true do |t|
    t.integer  "subscription_id"
    t.datetime "payment_date"
    t.string   "payer_first_name"
    t.string   "payer_last_name"
    t.string   "payer_email"
    t.string   "residence_country"
    t.string   "pending_reason"
    t.string   "mc_currency"
    t.string   "business"
    t.string   "payment_type"
    t.string   "payer_status"
    t.boolean  "test_ipn"
    t.float    "tax"
    t.string   "txn_id"
    t.string   "receiver_email"
    t.string   "payer_id"
    t.string   "receiver_id"
    t.string   "payment_status"
    t.float    "mc_gross"
    t.integer  "coupon_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["coupon_code_id"], name: "index_payments_on_coupon_code_id"
  add_index "payments", ["subscription_id"], name: "index_payments_on_subscription_id"

  create_table "plans", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "reception_delay",        default: 3600
    t.text     "description"
    t.boolean  "pause_ability",          default: true
    t.boolean  "switch_tipster_ability", default: true
    t.boolean  "profit_guaranteed",      default: true
    t.float    "discount",               default: 0.0
    t.float    "price"
    t.integer  "number_tipster"
    t.integer  "period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.integer  "user_id",                                            null: false
    t.string   "civility"
    t.date     "birthday"
    t.string   "address"
    t.string   "city"
    t.string   "country"
    t.string   "zip_code"
    t.string   "mobile_phone"
    t.string   "telephone"
    t.string   "favorite_betting_website"
    t.string   "know_website_from"
    t.integer  "secret_question"
    t.string   "answer_secret_question"
    t.boolean  "received_information_from_partners", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id"

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "sports", force: true do |t|
    t.string "name", null: false
  end

  create_table "subscription_tipsters", force: true do |t|
    t.integer  "tipster_id"
    t.integer  "subscription_id"
    t.boolean  "active",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_tipsters", ["subscription_id"], name: "index_subscription_tipsters_on_subscription_id"
  add_index "subscription_tipsters", ["tipster_id"], name: "index_subscription_tipsters_on_tipster_id"

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.boolean  "active",       default: false
    t.datetime "active_date"
    t.datetime "expired_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "using_coupon", default: false
  end

  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id"
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id"

  create_table "tips", force: true do |t|
    t.integer  "tipster_id",                   null: false
    t.string   "event",                        null: false
    t.string   "platform",                     null: false
    t.integer  "bet_type",                     null: false
    t.float    "odds",                         null: false
    t.float    "line"
    t.integer  "selection",                    null: false
    t.text     "advice",                       null: false
    t.float    "stake",                        null: false
    t.integer  "amount",                       null: false
    t.boolean  "correct",      default: false
    t.integer  "status",                       null: false
    t.integer  "published_by"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tips", ["tipster_id"], name: "index_tips_on_tipster_id"

# Could not dump table "users" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

end