# frozen_string_literal: true

class AddArchiveFieldsToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :archived_at, :datetime
    add_column :requests, :archived_by_id, :integer
  end
end
