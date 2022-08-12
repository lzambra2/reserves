# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :contact_email
      t.string :contact_phone
      t.text :address
      t.boolean :is_deleted, default: false
      t.string :disallowed_item_types
      t.timestamps
    end
  end
end
