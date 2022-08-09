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

ActiveRecord::Schema.define(version: 20_220_803_192_930) do
  create_table 'acquisition_requests', force: :cascade do |t|
    t.integer 'item_id'
    t.integer 'requested_by_id'
    t.text 'acquisition_reason'
    t.string 'status'
    t.integer 'cancelled_by_id'
    t.text 'cancellation_reason'
    t.datetime 'cancelled_at'
    t.integer 'acquired_by_id'
    t.datetime 'acquired_at'
    t.text 'acquisition_notes'
    t.text 'acquisition_source_type'
    t.text 'acquisition_source_name'
    t.integer 'list_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'location_id'
  end

  create_table 'audits', force: :cascade do |t|
    t.integer 'auditable_id'
    t.string 'auditable_type'
    t.integer 'associated_id'
    t.string 'associated_type'
    t.integer 'user_id'
    t.string 'user_type'
    t.string 'username'
    t.string 'action'
    t.text 'audited_changes'
    t.integer 'version', default: 0
    t.text 'comment'
    t.string 'remote_address'
    t.datetime 'created_at'
    t.string 'request_uuid'
    t.index %w[associated_id associated_type], name: 'associated_index'
    t.index %w[auditable_id auditable_type], name: 'auditable_index'
    t.index ['created_at'], name: 'index_audits_on_created_at'
    t.index ['request_uuid'], name: 'index_audits_on_request_uuid'
    t.index %w[user_id user_type], name: 'user_index'
  end

  create_table 'courses', force: :cascade do |t|
    t.string 'name'
    t.string 'code'
    t.integer 'student_count'
    t.string 'instructor'
    t.integer 'created_by_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'code_year'
    t.string 'code_faculty'
    t.string 'code_subject'
    t.string 'code_term'
    t.string 'code_credits'
    t.string 'code_section'
  end

  create_table 'courses_faculties', force: :cascade do |t|
    t.string 'name'
    t.string 'code'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'courses_subjects', force: :cascade do |t|
    t.string 'name'
    t.string 'code'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'items', force: :cascade do |t|
    t.integer 'request_id'
    t.string 'metadata_source'
    t.string 'metadata_source_id'
    t.string 'title'
    t.string 'author'
    t.string 'isbn'
    t.string 'callnumber'
    t.string 'publication_date'
    t.string 'publisher'
    t.string 'description'
    t.string 'edition'
    t.string 'loan_period'
    t.boolean 'provided_by_requestor', default: false
    t.string 'item_type'
    t.string 'copyright_options'
    t.text 'other_copyright_options'
    t.string 'format'
    t.text 'url'
    t.string 'status'
    t.string 'map_index_num'
    t.string 'journal_title'
    t.string 'volume'
    t.string 'page_number'
    t.string 'issue'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'ils_barcode'
    t.boolean 'physical_copy_required', default: false
  end

  create_table 'loan_periods', force: :cascade do |t|
    t.string 'duration'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'locations', force: :cascade do |t|
    t.string 'name'
    t.string 'contact_email'
    t.string 'contact_phone'
    t.text 'address'
    t.boolean 'is_deleted', default: false
    t.string 'disallowed_item_types'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'setting_bcc_request_status_change', default: false
    t.string 'ils_location_name'
    t.boolean 'setting_bcc_location_on_new_item', default: false
    t.string 'acquisitions_email'
  end

  create_table 'requests', force: :cascade do |t|
    t.integer 'requester_id'
    t.integer 'course_id'
    t.integer 'assigned_to_id'
    t.integer 'reserve_location_id'
    t.date 'requested_date'
    t.date 'completed_date'
    t.date 'cancelled_date'
    t.date 'reserve_start_date'
    t.date 'reserve_end_date'
    t.string 'status'
    t.boolean 'removed_from_reserves', default: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'requester_email'
    t.integer 'rollover_parent_id'
    t.datetime 'rolledover_at'
    t.datetime 'removed_at'
    t.integer 'removed_by_id'
  end

  create_table 'settings', force: :cascade do |t|
    t.string 'var', null: false
    t.text 'value'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['var'], name: 'index_settings_on_var', unique: true
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.string 'email'
    t.string 'phone'
    t.string 'user_type'
    t.string 'role'
    t.string 'department'
    t.string 'office'
    t.string 'uid'
    t.string 'library_uid'
    t.boolean 'active', default: true
    t.boolean 'admin', default: false
    t.integer 'location_id'
    t.integer 'created_by_id'
    t.datetime 'last_login'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end
end
