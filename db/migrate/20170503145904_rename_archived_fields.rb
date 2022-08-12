# frozen_string_literal: true

class RenameArchivedFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :requests, :archived_at, :removed_at
    rename_column :requests, :archived_by_id, :removed_by_id
  end
end
