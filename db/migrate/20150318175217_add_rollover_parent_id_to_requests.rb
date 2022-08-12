# frozen_string_literal: true

class AddRolloverParentIdToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :rollover_parent_id, :integer
    add_column :requests, :rolledover_at, :datetime
  end
end
