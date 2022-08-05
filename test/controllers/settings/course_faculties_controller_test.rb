require 'test_helper'

class Settings::CourseFacultiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @settings_course_faculty = settings_course_faculties(:one)
  end

  test 'should get index' do
    get settings_course_faculties_url
    assert_response :success
  end

  test 'should get new' do
    get new_settings_course_faculty_url
    assert_response :success
  end

  test 'should create settings_course_faculty' do
    assert_difference('Settings::CourseFaculty.count') do
      post settings_course_faculties_url, params: { settings_course_faculty: {} }
    end

    assert_redirected_to settings_course_faculty_url(Settings::CourseFaculty.last)
  end

  test 'should show settings_course_faculty' do
    get settings_course_faculty_url(@settings_course_faculty)
    assert_response :success
  end

  test 'should get edit' do
    get edit_settings_course_faculty_url(@settings_course_faculty)
    assert_response :success
  end

  test 'should update settings_course_faculty' do
    patch settings_course_faculty_url(@settings_course_faculty), params: { settings_course_faculty: {} }
    assert_redirected_to settings_course_faculty_url(@settings_course_faculty)
  end

  test 'should destroy settings_course_faculty' do
    assert_difference('Settings::CourseFaculty.count', -1) do
      delete settings_course_faculty_url(@settings_course_faculty)
    end

    assert_redirected_to settings_course_faculties_url
  end
end
