# frozen_string_literal: true

class SplitCourseCodeIntoSeparateFields < ActiveRecord::Migration[5.1]
  def change
    add_column :courses, :code_year, :string
    add_column :courses, :code_faculty, :string
    add_column :courses, :code_subject, :string
    add_column :courses, :code_term, :string
    add_column :courses, :code_credits, :string
    add_column :courses, :code_section, :string
  end
end
