# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :user_type
      t.string :role
      t.string :department
      t.string :office
      t.string :uid
      t.string :library_uid
      t.boolean :active, default: true
      t.boolean :admin, default: false
      t.integer :location_id
      t.integer :created_by_id
      t.datetime :last_login
      t.timestamps
    end
  end
end
