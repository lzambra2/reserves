# frozen_string_literal: true

require 'test_helper'

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = create(:course)

    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'list all courses' do
    create_list(:course, 10)

    get courses_path
    assert_response :success
    courses = get_instance_var(:courses)
    assert_equal 11, courses.size, '10 Courses + 1 from setup'
  end

  should 'show new course form' do
    get new_course_path
    assert_response :success
  end

  should 'create a new course' do
    assert_difference('Course.count') do
      post courses_path, params: { course: attributes_for(:course) }
      course = get_instance_var(:course)
      assert_equal 0, course.errors.size, 'Should be no errors'
      assert_redirected_to courses_path
    end
  end

  should 'show course details' do
    get course_path(@course)
    assert_response :success
  end

  should 'show get edit form' do
    get edit_course_path(@course)
    assert_response :success
  end

  should 'update an existing course' do
    old_course_code = @course.code

    patch course_path(@course), params: { course: { code: '2013_GL_ECON_S1_3500__3_A' } }
    course = get_instance_var(:course)
    assert_equal 0, course.errors.size, "Should be no errors, #{course.errors.messages}"
    assert_response :redirect
    assert_redirected_to courses_path

    assert_not_equal old_course_code, course.code, 'Old code is not there'
    assert_equal '2013_GL_ECON_S1_3500__3_A', course.code, 'Code was updated'
  end

  should 'destroy course' do
    assert_difference('Course.count', -1) do
      delete course_path(@course)
    end

    assert_redirected_to courses_path
  end
end
