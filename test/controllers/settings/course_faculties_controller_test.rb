require 'test_helper'

class Settings::CourseFacultiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
    @settings_course_faculty = create(:courses_faculty)
  end

  test 'should get index' do
    get settings_faculties_url
    assert_response :success
  end

  test 'should get new' do
    get new_settings_faculty_url
    assert_response :success
  end

  test 'should create settings_course_faculty and return to index' do
    assert_difference('Courses::Faculty.count') do
      post settings_faculties_url,
           params: { courses_faculty: { name: @settings_course_faculty.name, code: @settings_course_faculty.code } }
    end

    assert_redirected_to settings_faculties_path
  end

  test 'should show settings_course_faculty' do
    get settings_faculties_path
    assert_response :success
  end

  test 'should get edit' do
    get edit_settings_faculty_url(@settings_course_faculty)
    assert_response :success
  end

  test 'should update settings_course_faculty and return to index' do
    patch settings_faculty_url(@settings_course_faculty),
          params: { courses_faculty: { name: @settings_course_faculty.name, code: @settings_course_faculty.code } }
    assert_redirected_to settings_faculties_path
  end

  test 'should destroy settings_course_faculty' do
    assert_difference('Courses::Faculty.count', -1) do
      delete settings_faculty_url(@settings_course_faculty)
    end

    assert_redirected_to settings_faculties_url
  end
end
