# frozen_string_literal: true

class AddFieldToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :physical_copy_required, :boolean, default: false
  end
end
