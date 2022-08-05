class Courses::Faculty < ApplicationRecord
  ### IMPORTANT, DO NOT DELETE ###
  self.table_name_prefix = 'courses_'

  FACULTIES = %w[AP ED ES FA GL GS HH LE LIB LW S SB SC SCS YUL]

  ## VALIDATIONS
  validates_presence_of :code

  ## SCOPES
  default_scope -> { order('code asc') }

  ## methods
  def self.all_faculties
    @all = Courses::Faculty.pluck(:code)

    combined = FACULTIES + @all
    combined = combined.map { |c| c.upcase }.uniq

    combined.sort
  end
end
