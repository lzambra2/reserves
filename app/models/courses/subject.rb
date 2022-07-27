class Courses::Subject < ApplicationRecord
  ### IMPORTANT, DO NOT DELETE ###
  self.table_name_prefix = 'courses_'

  SUBJECTS ||= IO.readlines("#{Rails.root}/lib/course_subjects.txt").collect { |s| s.strip }

  ## VALIDATIONS
  validates_presence_of :code

  ## SCOPES
  default_scope -> { order('code asc') }

  ## methods
  def self.all_subjects
    @all = Courses::Subject.pluck(:code)

    combined = SUBJECTS + @all
    combined = combined.map { |c| c.upcase }.uniq

    combined.sort

    # if @all.size == 0
    #   return SUBJECTS
    # else
    #   return @all.pluck(:code)
    # end
  end
end
