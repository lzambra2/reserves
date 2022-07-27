require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  should 'create a valid Course' do
    course = build(:course)

    assert course.valid?, "Course should be valid, #{course.errors.messages}"

    assert_difference 'Course.count', 1 do
      course.save
    end
  end

  should 'not create an invalid course' do
    assert !build(:course, name: nil).valid?, 'Name is required'
    assert !build(:course, code: nil).valid?, 'Code is required'
    assert !build(:course, student_count: nil).valid?, 'Number of students is required'
    assert !build(:course, instructor: nil).valid?, 'Instructor name is required'
  end

  should 'save course code parts after save' do
    c = build(:course, code: '2013_GL_ECON_S1_2500__3_A')
    assert_nil c.code_year
    assert_nil c.code_term
    assert_nil c.code_faculty

    c.save

    assert_equal c.year, c.code_year
    assert_equal c.term, c.code_term
    assert_equal c.faculty, c.code_faculty
    assert_equal c.subject, c.code_subject
    assert_equal c.credits, c.code_credits
    assert_equal c.section, c.code_section
  end

  should 'not allow a course code with spaces in it' do
    assert !build(:course, code: '2013_GL_ECON_S1_2500 __3_A').valid?, 'Should not allow a course code with spaces'
  end

  should 'not allow duplicate course codes' do
    create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert !build(:course, code: '2013_GL_ECON_S1_2500__3_A').valid?, 'Duplicate course'
  end
  should 'validate course format properly' do
    assert build(:course, code: '2013_GL_ECON_S1_2500__3_A').valid?, 'Valid course code'

    # assert ! build(:couse, code: "flkjsadf").valid?, "Invalid course code"
  end

  ## TEST Code separator methods

  should 'insert into code value at the specified position' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    course.insert_into_code(0, '3000')
    assert_equal '3000_GL_ECON_S1_2500__3_A', course.code, 'Year should be 3000'
    course.insert_into_code(2, 'HIST')
    assert_equal '3000_GL_HIST_S1_2500__3_A', course.code, 'Subject should be HIST'
    course.insert_into_code(7, 'Z')
    assert_equal '3000_GL_HIST_S1_2500__3_Z', course.code, 'Section should be Z'
  end

  should 'get value from code' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal '2013', course.get_value_from_code(0), 'Should be 2013'
    assert_equal 'GL', course.get_value_from_code(1), 'Should be GL'
    assert_equal '3', course.get_value_from_code(6), 'Should be 3'
  end

  should 'set and return a proper year' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal '2013', course.year, 'Year should be 2013'

    course.year = '2014'
    assert_equal '2014', course.year, 'Year should now be 2014'
  end

  should 'set and return a proper faculty' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal 'GL', course.faculty, 'Year should be GL'

    course.faculty = 'AP'
    assert_equal 'AP', course.faculty, 'Year should now be AP'
  end

  should 'set and return a proper subject' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal 'ECON', course.subject, 'Year should be ECON'

    course.subject = 'HIST'
    assert_equal 'HIST', course.subject, 'Year should now be HIST'
  end

  should 'set and return a proper term' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal 'S1', course.term, 'Year should be S1'

    course.term = 'W'
    assert_equal 'W', course.term, 'Year should now be W'
  end

  should 'set and return a proper course id' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal '2500', course.course_id, 'Year should be 2500'

    course.course_id = '3500'
    assert_equal '3500', course.course_id, 'Year should now be 3500'
  end

  should 'set and return a proper credits' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal '3', course.credits, 'Year should be 3'

    course.credits = '6'
    assert_equal '6', course.credits, 'Year should now be 6'
  end

  should 'set and return a proper section' do
    course = create(:course, code: '2013_GL_ECON_S1_2500__3_A')

    assert_equal 'A', course.section, 'Year should be A'

    course.section = 'Z'
    assert_equal 'Z', course.section, 'Year should now be Z'
  end

  should 'not have negative or zero student enrollment' do
    assert !build(:course, student_count: -500).valid?, 'Student Enrollment must be greater than 0'
  end

  ## ROLLOVER ##
  should 'rollover an course, by making an exact copy and removing the id and timestmaps' do
    c = create(:course)

    course = c.rollover
    assert_not_equal course.created_at, c.created_at
    assert_not_equal course.updated_at, c.updated_at
    assert_equal '', course.year, 'Year should not be set'

    course.attributes.except(:id, :created_at, :updated_at, :year).each do |attribute|
      assert course[attribute] == c[attribute], "Attribute #{attribute} should match"
    end
  end

  should 'rollover course and set year' do
    c = create(:course, year: '2014')

    course = c.rollover('2015')
    assert_equal '2015', course.year, 'Years should match'

    course.attributes.except(:id, :created_at, :updated_at, :year).each do |attribute|
      assert course[attribute] == c[attribute], "Attribute #{attribute} should match"
    end
  end

  should 'rollover course and set year, credits and section' do
    c = create(:course, year: '2015', term: 'Y', credits: '3', section: 'A')

    course = c.rollover('2015', 'W', 'B', '9')
    assert_equal '2015', course.year
    assert_equal 'W', course.term
    assert_equal 'B', course.section
    assert_equal '9', course.credits
  end
end
