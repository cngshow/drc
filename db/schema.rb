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

ActiveRecord::Schema.define(version: 20170713172738) do

  create_table "checksum_details", force: :cascade do |t|
    t.integer "va_site_id", precision: 38, null: false
    t.integer "checksum_request_id", precision: 38, null: false
    t.integer "checksum_detail_id", precision: 38
    t.string "subset"
    t.string "checksum"
    t.string "failure_message"
    t.text "hl7_message"
    t.string "version"
    t.string "status", null: false
    t.date "start_time"
    t.date "finish_time"
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["checksum_detail_id"], name: "i_che_det_che_det_id"
    t.index ["checksum_request_id"], name: "i_che_det_che_req_id"
    t.index ["va_site_id"], name: "i_checksum_details_va_site_id"
  end

  create_table "checksum_requests", force: :cascade do |t|
    t.string "username", null: false
    t.string "domain", null: false
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["domain"], name: "i_checksum_requests_domain"
  end

  create_table "discovery_details", force: :cascade do |t|
    t.integer "va_site_id", precision: 38, null: false
    t.integer "discovery_request_id", precision: 38, null: false
    t.integer "discovery_detail_id", precision: 38
    t.string "subset", null: false
    t.string "status", null: false
    t.date "start_time"
    t.date "finish_time"
    t.string "failure_message"
    t.text "hl7_message"
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["discovery_detail_id"], name: "i_dis_det_dis_det_id"
    t.index ["discovery_request_id"], name: "i_dis_det_dis_req_id"
    t.index ["va_site_id"], name: "i_discovery_details_va_site_id"
  end

  create_table "discovery_requests", force: :cascade do |t|
    t.string "username", null: false
    t.string "domain", null: false
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["username", "domain"], name: "i_dis_req_use_dom"
  end

  create_table "log_events", force: :cascade do |t|
    t.string "hostname"
    t.string "application_name"
    t.integer "level", precision: 38
    t.string "tag"
    t.text "message"
    t.string "acknowledged_by"
    t.date "acknowledged_on"
    t.text "ack_comment"
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["acknowledged_by"], name: "i_log_events_acknowledged_by"
    t.index ["acknowledged_on"], name: "i_log_events_acknowledged_on"
    t.index ["application_name", "tag"], name: "i_log_eve_app_nam_tag"
    t.index ["application_name"], name: "i_log_events_application_name"
    t.index ["created_at"], name: "index_log_events_on_created_at"
    t.index ["hostname"], name: "index_log_events_on_hostname"
    t.index ["level"], name: "index_log_events_on_level"
    t.index ["tag"], name: "index_log_events_on_tag"
  end

  create_table "prisme_jobs", id: false, force: :cascade do |t|
    t.string "job_id", null: false
    t.string "job_name", null: false
    t.integer "status", precision: 38, null: false
    t.string "queue", null: false
    t.date "scheduled_at", null: false
    t.date "enqueued_at"
    t.date "started_at"
    t.date "completed_at"
    t.text "last_error"
    t.text "result"
    t.string "user"
    t.string "parent_job_id"
    t.string "root_job_id"
    t.boolean "leaf", default: true
    t.text "json_data"
    t.date "created_at"
    t.date "updated_at"
    t.string "job_tag"
    t.index ["completed_at"], name: "prisme_job_completed_at"
    t.index ["job_id"], name: "prisme_job_job_id", unique: true
    t.index ["job_name", "job_tag"], name: "i_prisme_jobs_job_name_job_tag"
    t.index ["job_name"], name: "prisme_job_job_name"
    t.index ["job_tag"], name: "index_prisme_jobs_on_job_tag"
    t.index ["parent_job_id"], name: "prisme_job_parent_job_id"
    t.index ["queue"], name: "prisme_job_queue"
    t.index ["root_job_id"], name: "prisme_job_root_job_id"
    t.index ["scheduled_at"], name: "prisme_job_scheduled_at"
    t.index ["status", "scheduled_at"], name: "prisme_job_status"
    t.index ["user", "scheduled_at"], name: "prisme_job_user"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "resource_id", precision: 38
    t.string "resource_type"
    t.date "created_at"
    t.date "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "i_rol_nam_res_typ_res_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "service_properties", force: :cascade do |t|
    t.integer "service_id", precision: 38
    t.string "key"
    t.string "value"
    t.integer "order_idx", precision: 38
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["service_id"], name: "i_ser_pro_ser_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "service_type"
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["name"], name: "service_name"
  end

  create_table "ssoi_users", force: :cascade do |t|
    t.string "ssoi_user_name", null: false
    t.boolean "admin_role_check", default: false, null: false
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["admin_role_check", "ssoi_user_name"], name: "idb0a8386313daf1e03ea066188859"
  end

  create_table "ssoi_users_roles", force: :cascade do |t|
    t.integer "ssoi_user_id", precision: 38
    t.integer "role_id", precision: 38
    t.text "role_metadata"
    t.index ["ssoi_user_id", "role_id"], name: "iec7ae089f5cc1b89ccfd87a6d86d1"
  end

  create_table "terminology_source_contents", force: :cascade do |t|
    t.string "upload_file_name"
    t.string "upload_content_type"
    t.integer "upload_file_size", precision: 38
    t.date "upload_updated_at"
    t.integer "terminology_source_package_id", precision: 38
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.index ["terminology_source_package_id"], name: "idx_terminology_package"
  end

  create_table "terminology_source_packages", force: :cascade do |t|
    t.string "user"
    t.date "created_at", null: false
    t.date "updated_at", null: false
  end

  create_table "user_activities", force: :cascade do |t|
    t.string "username"
    t.date "last_activity_at"
    t.string "request_url"
    t.index ["username", "last_activity_at"], name: "i_use_act_use_las_act_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.date "reset_password_sent_at"
    t.date "remember_created_at"
    t.integer "sign_in_count", precision: 38, default: 0, null: false
    t.date "current_sign_in_at"
    t.date "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.date "created_at", null: false
    t.date "updated_at", null: false
    t.boolean "admin_role_check", default: false, null: false
    t.index ["admin_role_check", "email"], name: "i_users_admin_role_check_email"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "i_users_reset_password_token", unique: true
  end

  create_table "users_roles", force: :cascade do |t|
    t.integer "user_id", precision: 38
    t.integer "role_id", precision: 38
    t.text "role_metadata"
    t.index ["user_id", "role_id"], name: "i_users_roles_user_id_role_id"
  end

  create_table "uuid_props", id: false, force: :cascade do |t|
    t.string "uuid"
    t.text "json_data"
    t.date "created_at", null: false
    t.date "updated_at", null: false
  end

  create_table "va_groups", force: :cascade do |t|
    t.string "name"
    t.string "member_sites"
    t.string "member_groups"
    t.date "created_at", null: false
    t.date "updated_at", null: false
  end

  create_table "va_sites", id: false, force: :cascade do |t|
    t.string "va_site_id", null: false
    t.string "name", null: false
    t.string "site_type", null: false
    t.string "message_type", null: false
    t.date "created_at", null: false
    t.date "updated_at", null: false
  end

  create_table "vuids", primary_key: "next_vuid", force: :cascade do |t|
    t.integer "start_vuid", limit: 19, precision: 19, null: false
    t.integer "end_vuid", limit: 19, precision: 19, null: false
    t.date "request_datetime", null: false
    t.text "request_reason"
    t.string "username"
    t.index ["request_datetime"], name: "i_vuids_request_datetime"
    t.index ["start_vuid", "end_vuid"], name: "idx_vuids_start_end"
    t.index ["username"], name: "index_vuids_on_username"
  end

  add_foreign_key "service_properties", "services"
  add_foreign_key "terminology_source_contents", "terminology_source_packages"
end
