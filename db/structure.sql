CREATE TABLE "accounts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "rolable_id" integer, "rolable_type" varchar(255), "email" varchar(255) DEFAULT '' NOT NULL, "encrypted_password" varchar(255) DEFAULT '' NOT NULL, "reset_password_token" varchar(255), "reset_password_sent_at" datetime, "remember_created_at" datetime, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar(255), "last_sign_in_ip" varchar(255), "confirmation_token" varchar(255), "confirmed_at" datetime, "confirmation_sent_at" datetime);
CREATE TABLE "admins" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "full_name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "areas" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "opta_area_id" integer, "parent_id" integer, "name" varchar(255), "country_code" varchar(255), "active" boolean DEFAULT 't');
CREATE TABLE "authorizations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subscriber_id" integer, "provider" varchar(255), "uid" varchar(255), "avatar_url" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "bet_types" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "sport_id" integer, "code" varchar(255), "betclic_code" varchar(255), "name" varchar(255), "other_name" varchar(255), "definition" varchar(255), "example" varchar(255), "has_line" boolean DEFAULT 't');
CREATE TABLE "competitions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "opta_competition_id" integer, "opta_area_id" integer, "sport_id" integer, "name" varchar(255), "fr_name" varchar(255), "active" boolean DEFAULT 't');
CREATE TABLE "coupon_codes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subscriber_id" integer, "code" varchar(255) NOT NULL, "source" varchar(255), "is_used" boolean DEFAULT 'f', "used_at" datetime, "created_at" datetime NOT NULL);
CREATE TABLE "matches" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "opta_match_id" integer, "sport_id" integer, "opta_competition_id" integer, "team_a" varchar(255), "team_b" varchar(255), "name" varchar(255), "betclic_match_id" varchar(255), "betclic_event_id" varchar(255), "start_at" datetime, "status" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "payments" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subscription_id" integer, "coupon_code_id" integer, "payment_date" datetime, "payer_first_name" varchar(255), "payer_last_name" varchar(255), "payer_email" varchar(255), "residence_country" varchar(255), "pending_reason" varchar(255), "mc_currency" varchar(255), "business" varchar(255), "payment_type" varchar(255), "payer_status" varchar(255), "test_ipn" boolean, "tax" float, "txn_id" varchar(255), "receiver_email" varchar(255), "payer_id" varchar(255), "receiver_id" varchar(255), "payment_status" varchar(255), "mc_gross" float, "paykey" varchar(255), "paid_for" varchar(255), "tipster_ids" varchar(255), "amount" float, "enable_history" boolean DEFAULT 'f', "is_recurring" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "plans" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "reception_delay" integer DEFAULT 0, "description" text, "pause_ability" boolean DEFAULT 't', "switch_tipster_ability" boolean DEFAULT 't', "profit_guaranteed" boolean DEFAULT 't', "discount" float DEFAULT 0, "price" float, "number_tipster" integer, "period" integer, "adding_price" float, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "platforms" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "code" varchar(255) NOT NULL, "name" varchar(255) NOT NULL);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "seasons" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "opta_season_id" integer, "opta_competition_id" integer, "name" varchar(255), "start_date" datetime, "end_date" datetime, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "sessions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "session_id" varchar(255) NOT NULL, "data" text, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "sports" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) NOT NULL, "code" varchar(255) NOT NULL, "position" integer);
CREATE TABLE "sports_tipsters" ("sport_id" integer NOT NULL, "tipster_id" integer NOT NULL);
CREATE TABLE "subscribers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar(255), "last_name" varchar(255), "nickname" varchar(255), "gender" boolean DEFAULT 't', "civility" varchar(255), "birthday" date, "address" varchar(255), "city" varchar(255), "country" varchar(255), "zip_code" varchar(255), "phone_indicator" varchar(255), "mobile_phone" varchar(255), "telephone" varchar(255), "favorite_beting_website" varchar(255), "know_website_from" varchar(255), "secret_question" integer, "answer_secret_question" varchar(255), "receive_info_from_partners" boolean DEFAULT 'f', "receive_tip_methods" varchar(255), "created_by_omniauth" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "subscription_tipsters" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "tipster_id" integer, "subscription_id" integer, "active" boolean DEFAULT 'f', "is_primary" boolean DEFAULT 'f', "payment_id" integer, "active_at" datetime, "expired_at" datetime, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "subscriptions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subscriber_id" integer, "plan_id" integer, "using_coupon" boolean DEFAULT 'f', "active" boolean DEFAULT 'f', "is_one_shoot" boolean DEFAULT 'f', "active_at" datetime, "expired_at" datetime, "payment_status" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "tips" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "author_id" integer NOT NULL, "author_type" varchar(255) NOT NULL, "match_id" integer, "sport_id" integer NOT NULL, "platform_id" integer NOT NULL, "bet_type_id" integer NOT NULL, "odds" float NOT NULL, "selection" varchar(255) NOT NULL, "line" float, "advice" text NOT NULL, "amount" integer NOT NULL, "correct" boolean DEFAULT 'f', "status" integer NOT NULL, "free" boolean DEFAULT 'f', "published_by" integer, "published_at" datetime, "finished_at" datetime, "finished_by" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "tipsters" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "display_name" varchar(255), "full_name" varchar(255), "avatar" varchar(255), "status" integer, "active" boolean DEFAULT 't', "description" text, "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "index_accounts_on_confirmation_token" ON "accounts" ("confirmation_token");
CREATE UNIQUE INDEX "index_accounts_on_email" ON "accounts" ("email");
CREATE UNIQUE INDEX "index_accounts_on_reset_password_token" ON "accounts" ("reset_password_token");
CREATE INDEX "index_accounts_on_rolable_id_and_rolable_type" ON "accounts" ("rolable_id", "rolable_type");
CREATE INDEX "index_authorizations_on_subscriber_id" ON "authorizations" ("subscriber_id");
CREATE INDEX "index_authorizations_on_uid" ON "authorizations" ("uid");
CREATE INDEX "index_bet_types_on_sport_id" ON "bet_types" ("sport_id");
CREATE INDEX "index_competitions_on_opta_area_id" ON "competitions" ("opta_area_id");
CREATE INDEX "index_competitions_on_opta_competition_id" ON "competitions" ("opta_competition_id");
CREATE INDEX "index_competitions_on_sport_id" ON "competitions" ("sport_id");
CREATE INDEX "index_coupon_codes_on_subscriber_id" ON "coupon_codes" ("subscriber_id");
CREATE INDEX "index_matches_on_opta_competition_id" ON "matches" ("opta_competition_id");
CREATE INDEX "index_matches_on_opta_match_id" ON "matches" ("opta_match_id");
CREATE INDEX "index_matches_on_sport_id" ON "matches" ("sport_id");
CREATE INDEX "index_payments_on_coupon_code_id" ON "payments" ("coupon_code_id");
CREATE INDEX "index_payments_on_subscription_id" ON "payments" ("subscription_id");
CREATE INDEX "index_seasons_on_opta_competition_id" ON "seasons" ("opta_competition_id");
CREATE INDEX "index_seasons_on_opta_season_id" ON "seasons" ("opta_season_id");
CREATE UNIQUE INDEX "index_sessions_on_session_id" ON "sessions" ("session_id");
CREATE INDEX "index_sessions_on_updated_at" ON "sessions" ("updated_at");
CREATE INDEX "index_sports_tipsters_on_sport_id_and_tipster_id" ON "sports_tipsters" ("sport_id", "tipster_id");
CREATE INDEX "index_subscription_tipsters_on_payment_id" ON "subscription_tipsters" ("payment_id");
CREATE INDEX "index_subscription_tipsters_on_subscription_id" ON "subscription_tipsters" ("subscription_id");
CREATE INDEX "index_subscription_tipsters_on_tipster_id" ON "subscription_tipsters" ("tipster_id");
CREATE INDEX "index_subscriptions_on_plan_id" ON "subscriptions" ("plan_id");
CREATE INDEX "index_subscriptions_on_subscriber_id" ON "subscriptions" ("subscriber_id");
CREATE INDEX "index_tips_on_author_id_and_author_type" ON "tips" ("author_id", "author_type");
CREATE INDEX "index_tips_on_bet_type_id" ON "tips" ("bet_type_id");
CREATE INDEX "index_tips_on_match_id" ON "tips" ("match_id");
CREATE INDEX "index_tips_on_platform_id" ON "tips" ("platform_id");
CREATE INDEX "index_tips_on_sport_id" ON "tips" ("sport_id");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20140302155201');

INSERT INTO schema_migrations (version) VALUES ('20140302161125');

INSERT INTO schema_migrations (version) VALUES ('20140302161650');

INSERT INTO schema_migrations (version) VALUES ('20140302162554');

INSERT INTO schema_migrations (version) VALUES ('20140303082816');

INSERT INTO schema_migrations (version) VALUES ('20140303083019');

INSERT INTO schema_migrations (version) VALUES ('20140303083529');

INSERT INTO schema_migrations (version) VALUES ('20140303085224');

INSERT INTO schema_migrations (version) VALUES ('20140303085527');

INSERT INTO schema_migrations (version) VALUES ('20140303085651');

INSERT INTO schema_migrations (version) VALUES ('20140303085744');

INSERT INTO schema_migrations (version) VALUES ('20140303085856');

INSERT INTO schema_migrations (version) VALUES ('20140303090024');

INSERT INTO schema_migrations (version) VALUES ('20140303090758');

INSERT INTO schema_migrations (version) VALUES ('20140312023800');

INSERT INTO schema_migrations (version) VALUES ('20140312025726');

INSERT INTO schema_migrations (version) VALUES ('20140318080820');

INSERT INTO schema_migrations (version) VALUES ('20140318102548');

INSERT INTO schema_migrations (version) VALUES ('20140319073059');

INSERT INTO schema_migrations (version) VALUES ('20140319142648');
