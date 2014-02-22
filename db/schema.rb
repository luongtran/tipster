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

ActiveRecord::Schema.define(version: 20140222033818) do

  create_table "authorizations", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["uid"], name: "index_authorizations_on_uid", using: :btree
  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree

  create_table "carts_tipsters", force: true do |t|
    t.integer "cart_id"
    t.integer "tipster_id"
  end

  create_table "coupon_codes", force: true do |t|
    t.integer  "user_id"
    t.string   "code",                       null: false
    t.string   "source"
    t.boolean  "is_used",    default: false
    t.datetime "used_at"
    t.datetime "created_at",                 null: false
  end

  add_index "coupon_codes", ["user_id"], name: "index_coupon_codes_on_user_id", using: :btree

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

  add_index "invoices", ["user_id"], name: "index_invoices_on_user_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "subscription_id"
    t.datetime "payment_date"
    t.string   "payer_first_name"
    t.string   "payer_last_name"
    t.string   "payer_email"
    t.string   "residence_country"
    t.string   "pending_reason"
    t.string   "mc_currency"
    t.string   "business_email"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coupon_code_id"
  end

  add_index "payments", ["coupon_code_id"], name: "index_payments_on_coupon_code_id", using: :btree
  add_index "payments", ["subscription_id"], name: "index_payments_on_subscription_id", using: :btree

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "period"
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

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "subscriber_tipsters", force: true do |t|
    t.integer  "tipster_id"
    t.integer  "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriber_tipsters", ["subscription_id"], name: "index_subscriber_tipsters_on_subscription_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.datetime "active_date"
    t.datetime "expired_date"
  end

  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
