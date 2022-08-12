# frozen_string_literal: true

class ChangeCommentTypeInAudits < ActiveRecord::Migration[5.1]
  def up
    change_column :audits, :comment, :text
  end

  def down
    change_column :audits, :comment, :string
  end
end
