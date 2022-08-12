# frozen_string_literal: true

class CreateCoursesFaculties < ActiveRecord::Migration[5.1]
  def change
    create_table :courses_faculties do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
