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

ActiveRecord::Schema.define(version: 20140422071617) do

  create_table "accounts", force: true do |t|
    t.integer  "rolable_id"
    t.string   "rolable_type"
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
  end

  add_index "accounts", ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true, using: :btree
  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  add_index "accounts", ["rolable_id", "rolable_type"], name: "index_accounts_on_rolable_id_and_rolable_type", using: :btree

  create_table "admins", force: true do |t|
    t.string   "full_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authorizations", force: true do |t|
    t.integer  "subscriber_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["subscriber_id"], name: "index_authorizations_on_subscriber_id", using: :btree
  add_index "authorizations", ["uid"], name: "index_authorizations_on_uid", using: :btree

  create_table "bet_types", force: true do |t|
    t.string  "code"
    t.string  "sport_code"
    t.string  "name"
    t.boolean "has_line",   default: true
    t.string  "other_name"
    t.text    "definition"
    t.text    "example"
    t.integer "position"
  end

  add_index "bet_types", ["sport_code"], name: "index_bet_types_on_sport_code", using: :btree

  create_table "bookmarker_matches", force: true do |t|
    t.integer  "match_id",         null: false
    t.string   "bookmarker_code",  null: false
    t.string   "sport_code"
    t.string   "name",             null: false
    t.string   "team_a_name"
    t.string   "team_b_name"
    t.integer  "competition_id"
    t.string   "competition_name"
    t.datetime "start_at",         null: false
    t.datetime "updated_at"
  end

  create_table "bookmarkers", force: true do |t|
    t.string "code", null: false
    t.string "name", null: false
  end

  create_table "coupon_codes", force: true do |t|
    t.integer  "subscriber_id"
    t.string   "code",                          null: false
    t.string   "source"
    t.boolean  "is_used",       default: false
    t.datetime "used_at"
    t.datetime "created_at",                    null: false
  end

  add_index "coupon_codes", ["subscriber_id"], name: "index_coupon_codes_on_subscriber_id", using: :btree

  create_table "manual_matches", force: true do |t|
    t.string   "name"
    t.string   "sport_code"
    t.datetime "created_at"
  end

  create_table "opta_areas", force: true do |t|
    t.integer  "opta_area_id"
    t.string   "name"
    t.string   "country_code"
    t.datetime "update_at"
  end

  create_table "opta_competitions", force: true do |t|
    t.integer  "opta_area_id"
    t.integer  "opta_competition_id"
    t.string   "sport_code"
    t.string   "name"
    t.boolean  "active",              default: true
    t.datetime "updated_at"
  end

  add_index "opta_competitions", ["opta_competition_id"], name: "index_opta_competitions_on_opta_competition_id", using: :btree
  add_index "opta_competitions", ["sport_code"], name: "index_opta_competitions_on_sport_code", using: :btree

  create_table "opta_matches", force: true do |t|
    t.integer  "opta_match_id"
    t.string   "type"
    t.string   "name"
    t.string   "sport_code"
    t.datetime "start_at"
    t.datetime "updated_at"
  end

  add_index "opta_matches", ["opta_match_id"], name: "index_opta_matches_on_opta_match_id", using: :btree
  add_index "opta_matches", ["sport_code"], name: "index_opta_matches_on_sport_code", using: :btree

  create_table "opta_seasons", force: true do |t|
    t.integer  "opta_season_id"
    t.integer  "opta_competition_id"
    t.string   "name"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "updated_at"
  end

  add_index "opta_seasons", ["opta_competition_id"], name: "index_opta_seasons_on_opta_competition_id", using: :btree
  add_index "opta_seasons", ["opta_season_id"], name: "index_opta_seasons_on_opta_season_id", using: :btree

  create_table "opta_tours", force: true do |t|
    t.integer  "opta_tour_id"
    t.string   "name"
    t.datetime "update_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "subscription_id"
    t.integer  "coupon_code_id"
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
    t.string   "paykey"
    t.string   "paid_for"
    t.string   "tipster_ids"
    t.float    "amount"
    t.boolean  "enable_history",    default: false
    t.boolean  "is_recurring",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["coupon_code_id"], name: "index_payments_on_coupon_code_id", using: :btree
  add_index "payments", ["subscription_id"], name: "index_payments_on_subscription_id", using: :btree

  create_table "plans", force: true do |t|
    t.string   "title"
    t.integer  "reception_delay",        default: 0
    t.text     "description"
    t.boolean  "pause_ability",          default: true
    t.boolean  "switch_tipster_ability", default: true
    t.boolean  "profit_guaranteed",      default: true
    t.float    "discount",               default: 0.0
    t.float    "price"
    t.integer  "number_tipster"
    t.integer  "period"
    t.float    "adding_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sports", force: true do |t|
    t.string  "name",     null: false
    t.string  "code",     null: false
    t.integer "position"
  end

  create_table "sports_tipsters", force: true do |t|
    t.string  "sport_code"
    t.integer "tipster_id"
  end

  add_index "sports_tipsters", ["sport_code", "tipster_id"], name: "index_sports_tipsters_on_sport_code_and_tipster_id", using: :btree

  create_table "subscribers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.boolean  "gender",                     default: true
    t.string   "civility"
    t.date     "birthday"
    t.string   "address"
    t.string   "city"
    t.string   "country"
    t.string   "zip_code"
    t.string   "phone_indicator"
    t.string   "mobile_phone"
    t.string   "telephone"
    t.string   "favorite_beting_website"
    t.string   "know_website_from"
    t.integer  "secret_question"
    t.string   "answer_secret_question"
    t.boolean  "receive_info_from_partners", default: false
    t.string   "receive_tip_methods"
    t.boolean  "created_by_omniauth",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_tipsters", force: true do |t|
    t.integer  "tipster_id"
    t.integer  "subscription_id"
    t.boolean  "active",          default: false
    t.boolean  "is_primary",      default: false
    t.integer  "payment_id"
    t.datetime "active_at"
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_tipsters", ["payment_id"], name: "index_subscription_tipsters_on_payment_id", using: :btree
  add_index "subscription_tipsters", ["subscription_id"], name: "index_subscription_tipsters_on_subscription_id", using: :btree
  add_index "subscription_tipsters", ["tipster_id"], name: "index_subscription_tipsters_on_tipster_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "subscriber_id"
    t.integer  "plan_id"
    t.boolean  "using_coupon",   default: false
    t.boolean  "active",         default: false
    t.boolean  "is_one_shoot",   default: false
    t.datetime "active_at"
    t.datetime "expired_at"
    t.string   "payment_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id", using: :btree
  add_index "subscriptions", ["subscriber_id"], name: "index_subscriptions_on_subscriber_id", using: :btree

  create_table "tip_journals", force: true do |t|
    t.integer  "tip_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.string   "event"
    t.datetime "created_at"
  end

  create_table "tips", force: true do |t|
    t.integer  "author_id",                           null: false
    t.string   "author_type",                         null: false
    t.integer  "match_id"
    t.string   "match_type"
    t.string   "bookmarker_code",                     null: false
    t.string   "bet_type_code",                       null: false
    t.float    "odds",                                null: false
    t.string   "selection",                           null: false
    t.text     "advice",                              null: false
    t.integer  "amount",                              null: false
    t.string   "sport_code",                          null: false
    t.integer  "opta_match_id"
    t.integer  "opta_competition_id"
    t.boolean  "free",                default: false
    t.integer  "status",                              null: false
    t.integer  "published_by"
    t.datetime "published_at"
    t.integer  "last_rejected_by"
    t.integer  "last_rejected_at"
    t.text     "last_reject_reason"
    t.datetime "finished_at"
    t.integer  "finished_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tips", ["author_id", "author_type"], name: "index_tips_on_author_id_and_author_type", using: :btree
  add_index "tips", ["bet_type_code"], name: "index_tips_on_bet_type_code", using: :btree
  add_index "tips", ["bookmarker_code"], name: "index_tips_on_bookmarker_code", using: :btree
  add_index "tips", ["match_id"], name: "index_tips_on_match_id", using: :btree
  add_index "tips", ["opta_competition_id"], name: "index_tips_on_opta_competition_id", using: :btree
  add_index "tips", ["opta_match_id"], name: "index_tips_on_opta_match_id", using: :btree
  add_index "tips", ["sport_code"], name: "index_tips_on_sport_code", using: :btree

  create_table "tipster_statistics", force: true do |t|
    t.integer  "tipster_id",                  null: false
    t.text     "data",       limit: 16777215
    t.datetime "updated_at"
  end

  add_index "tipster_statistics", ["tipster_id"], name: "index_tipster_statistics_on_tipster_id", using: :btree

  create_table "tipsters", force: true do |t|
    t.string   "display_name"
    t.string   "full_name"
    t.string   "avatar"
    t.integer  "status"
    t.boolean  "active",       default: true
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
