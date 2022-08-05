class CreateCoursesSubjects < ActiveRecord::Migration[5.1]
  def change
    create_table :courses_subjects do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
