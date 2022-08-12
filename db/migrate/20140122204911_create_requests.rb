# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.integer :requester_id
      t.integer :course_id
      t.integer :assigned_to_id
      t.integer :reserve_location_id
      t.date :requested_date
      t.date :completed_date
      t.date :cancelled_date
      t.date :reserve_start_date
      t.date :reserve_end_date
      t.string :status
      t.boolean :removed_from_reserves, default: false

      t.timestamps
    end
  end
end
