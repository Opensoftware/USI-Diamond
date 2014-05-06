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

ActiveRecord::Schema.define(version: 20140502153705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academy_unit_translations", force: true do |t|
    t.integer  "academy_unit_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "academy_unit_translations", ["academy_unit_id"], name: "index_academy_unit_translations_on_academy_unit_id", using: :btree
  add_index "academy_unit_translations", ["locale"], name: "index_academy_unit_translations_on_locale", using: :btree

  create_table "academy_units", force: true do |t|
    t.string   "short_name"
    t.string   "code"
    t.string   "name"
    t.string   "type"
    t.integer  "overriding_id"
    t.boolean  "visible",       default: true
    t.integer  "annual_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annuals", force: true do |t|
    t.string   "name"
    t.boolean  "locked",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_translations", force: true do |t|
    t.integer  "course_id",  null: false
    t.string   "locale",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "course_translations", ["course_id"], name: "index_course_translations_on_course_id", using: :btree
  add_index "course_translations", ["locale"], name: "index_course_translations_on_locale", using: :btree

  create_table "courses", force: true do |t|
    t.string   "short_name"
    t.string   "code"
    t.string   "name"
    t.integer  "academy_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diamond_course_theses", force: true do |t|
    t.integer  "course_id"
    t.integer  "thesis_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diamond_theses", force: true do |t|
    t.text     "title"
    t.text     "description"
    t.integer  "student_amount", default: 1
    t.string   "state",          default: "unaccepted"
    t.integer  "supervisor_id"
    t.integer  "thesis_type_id"
    t.integer  "department_id"
    t.integer  "annual_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diamond_thesis_enrollments", force: true do |t|
    t.string   "state",      default: "pending"
    t.integer  "thesis_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diamond_thesis_enrollments", ["student_id"], name: "enrollments_by_student", using: :btree
  add_index "diamond_thesis_enrollments", ["thesis_id", "student_id"], name: "enrollments_by_thesis_student", using: :btree
  add_index "diamond_thesis_enrollments", ["thesis_id"], name: "enrollments_by_thesis", using: :btree

  create_table "diamond_thesis_messages", force: true do |t|
    t.integer  "audited_id"
    t.integer  "user_id"
    t.string   "klazz"
    t.string   "state",      default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diamond_thesis_messages", ["klazz", "audited_id"], name: "diamond_thesis_messages_by_klazz_audited_id", using: :btree
  add_index "diamond_thesis_messages", ["klazz", "user_id"], name: "diamond_thesis_messages_by_klazz_user_id", using: :btree

  create_table "diamond_thesis_state_audits", force: true do |t|
    t.integer  "thesis_id"
    t.integer  "employee_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diamond_thesis_state_audits", ["thesis_id", "employee_id"], name: "by_thesis_employee", using: :btree
  add_index "diamond_thesis_state_audits", ["thesis_id"], name: "audits_by_thesis", using: :btree

  create_table "diamond_thesis_translations", force: true do |t|
    t.integer  "diamond_thesis_id", null: false
    t.string   "locale",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.text     "description"
  end

  add_index "diamond_thesis_translations", ["diamond_thesis_id"], name: "index_diamond_thesis_translations_on_diamond_thesis_id", using: :btree
  add_index "diamond_thesis_translations", ["locale"], name: "index_diamond_thesis_translations_on_locale", using: :btree

  create_table "diamond_thesis_type_translations", force: true do |t|
    t.integer  "diamond_thesis_type_id", null: false
    t.string   "locale",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "short_name"
  end

  add_index "diamond_thesis_type_translations", ["diamond_thesis_type_id"], name: "index_c2043907fe7ed9d8ed5b7cf721b651883e708a26", using: :btree
  add_index "diamond_thesis_type_translations", ["locale"], name: "index_diamond_thesis_type_translations_on_locale", using: :btree

  create_table "diamond_thesis_types", force: true do |t|
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_titles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.string   "surname"
    t.string   "name"
    t.string   "room"
    t.string   "phone_number"
    t.string   "www"
    t.boolean  "delta",             default: true, null: false
    t.integer  "academy_unit_id"
    t.integer  "employee_title_id"
    t.integer  "language_id"
    t.integer  "building_id"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollment_semesters", force: true do |t|
    t.datetime "thesis_enrollments_begin"
    t.datetime "thesis_enrollments_end"
    t.datetime "elective_enrollments_begin"
    t.datetime "elective_enrollments_end"
    t.integer  "annual_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "language_translations", force: true do |t|
    t.integer  "language_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "language_translations", ["language_id"], name: "index_language_translations_on_language_id", using: :btree
  add_index "language_translations", ["locale"], name: "index_language_translations_on_locale", using: :btree

  create_table "languages", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permission_roles", force: true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  add_index "permission_roles", ["permission_id", "role_id"], name: "by_permission_role", using: :btree

  create_table "permissions", force: true do |t|
    t.string   "action"
    t.string   "subject_class"
    t.integer  "subject_id"
    t.string   "condition"
    t.text     "block"
    t.boolean  "cannot",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "role_translations", force: true do |t|
    t.integer  "role_id",    null: false
    t.string   "locale",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "role_translations", ["locale"], name: "index_role_translations_on_locale", using: :btree
  add_index "role_translations", ["role_id"], name: "index_role_translations_on_role_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",        limit: 40
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.integer  "current_annual_id"
    t.integer  "current_semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_studies", force: true do |t|
    t.integer  "semester_number", default: 1
    t.integer  "student_id"
    t.integer  "studies_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_studies", ["student_id", "studies_id"], name: "by_student_studies", using: :btree
  add_index "student_studies", ["studies_id", "student_id", "semester_number"], name: "by_studies_student_semester_number", using: :btree
  add_index "student_studies", ["studies_id", "student_id"], name: "by_studies_student", using: :btree

  create_table "students", force: true do |t|
    t.string   "name"
    t.string   "surname"
    t.integer  "index_number",  limit: 8
    t.integer  "passed_ects"
    t.float    "average_grade"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studies", force: true do |t|
    t.integer  "course_id"
    t.integer  "study_type_id"
    t.integer  "study_degree_id"
    t.integer  "specialty_id"
    t.integer  "faculty_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "studies", ["course_id"], name: "studies_by_course", using: :btree
  add_index "studies", ["faculty_id"], name: "studies_by_faculty", using: :btree

  create_table "study_degree_translations", force: true do |t|
    t.integer  "study_degree_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "short_name"
  end

  add_index "study_degree_translations", ["locale"], name: "index_study_degree_translations_on_locale", using: :btree
  add_index "study_degree_translations", ["study_degree_id"], name: "index_study_degree_translations_on_study_degree_id", using: :btree

  create_table "study_degrees", force: true do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_type_translations", force: true do |t|
    t.integer  "study_type_id", null: false
    t.string   "locale",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "short_name"
  end

  add_index "study_type_translations", ["locale"], name: "index_study_type_translations_on_locale", using: :btree
  add_index "study_type_translations", ["study_type_id"], name: "index_study_type_translations_on_study_type_id", using: :btree

  create_table "study_types", force: true do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.integer  "status"
    t.string   "verifable_type"
    t.datetime "last_request_at"
    t.string   "perishable_token",   default: "", null: false
    t.integer  "failed_login_count"
    t.text     "preferences"
    t.integer  "role_id"
    t.integer  "verifable_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["verifable_id"], name: "by_verifable", using: :btree

end
