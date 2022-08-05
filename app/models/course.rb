class Course < ApplicationRecord
  # COURSE FORMAT
  # YEAR_FACULTY_SUBJECT_TERM_COURSEID__CREDITS_SECTION    i.e. 2013_GL_ECON_S1_2500__3_A ignoring EN_A_LECT_01

  # CONSTANTS
  FACULTIES = %w[AP ED ES FA GL GS HH LE LIB LW S SB SC SCS YUL]
  SECTIONS = ('A'..'Z')

  ACADEMIC_YEARS = if Date.today.month > 8
                     Date.today.year..Date.today.year + 1
                   else
                     Date.today.year - 1..Date.today.year
                   end

  ACADEMIC_YEARS_FULL = ACADEMIC_YEARS.collect { |year| ["#{year}/#{year + 1}", year] }

  TERMS = %w[F W FW Y S SU S1 S2]
  TERM_NAMES = %w[Fall Winter Fall/Winter Year Summer Summer1 Summer2]
  TERM_CREDITS = %w[1 3 4 6 9]
  SUBJECTS ||= IO.readlines("#{Rails.root}/lib/course_subjects.txt").collect { |s| s.strip }

  # VALIDATIONS
  validates_uniqueness_of :code, message: 'Duplicate Course Code, Someone Has Made a Request For that Course.'

  validates_presence_of :name, :code, :student_count, :instructor
  validates_presence_of :year, :faculty, :subject, :term, :credits, :section
  validates_presence_of :course_id, message: 'Course Number is required'
  validates :code, format: { without: /\s/ }
  validates_numericality_of :course_id, message: 'Course Number must be a number'
  validates_numericality_of :year, message: 'Year must be a number'
  validates_numericality_of :credits, message: 'Credits must be a number'
  validates_numericality_of :student_count, message: 'Enrollment must be a number'
  validates_numericality_of :student_count, greater_than: 0, message: 'Student Enrollment must be greater than 0'

  # RELATIONS
  has_many :requests
  has_many :reserve_locations, through: :requests
  has_many :items, through: :requests

  # SCOPES
  scope :active_courses, -> { where('created_at >= ?', 20.months.ago) }

  # CALLBACKS
  before_save :update_code_columns

  # AUDITS
  audited
  # has_associated_audits

  # SPECIAL ACCESSORS TO BREAK UP THE CODE

  def year
    get_value_from_code(0)
  end

  def year=(year)
    insert_into_code(0, year)
  end

  def faculty
    get_value_from_code(1)
  end

  def faculty=(faculty)
    insert_into_code(1, faculty)
  end

  def subject
    get_value_from_code(2)
  end

  def subject=(subject)
    insert_into_code(2, subject)
  end

  def term
    get_value_from_code(3)
  end

  def term=(term)
    insert_into_code(3, term)
  end

  def course_id
    get_value_from_code(4)
  end

  def course_id=(course_id)
    insert_into_code(4, course_id)
  end

  def credits
    get_value_from_code(6)
  end

  def credits=(credits)
    insert_into_code(6, credits)
  end

  def section
    get_value_from_code(7)
  end

  def section=(section)
    insert_into_code(7, section)
  end

  ####### HELPER METHODS #########

  def get_value_from_code(position)
    self.code = '_______'   if code.blank?
    code.split('_')[position]
  end

  def insert_into_code(position, value)
    self.code = '_______'   if code.blank?
    broken = code.split('_')
    broken[position] = value
    self.code = broken.join('_')
  end

  def rollover(course_year = '', course_term = '', course_section = '', course_credits = '')
    c = Course.new(attributes)

    c.id = nil
    c.created_at = nil
    c.updated_at = nil
    c.year = course_year
    c.term = course_term
    c.credits = course_credits
    c.section = course_section
    c.student_count = nil

    c.save(validate: false)

    c
  end

  # CALLBACK Implementation
  private

  def update_code_columns
    self[:code_year] = year
    self[:code_faculty] = faculty
    self[:code_subject] = subject
    self[:code_term] = term
    self[:code_credits] = credits
    self[:code_section] = section
  end
end
