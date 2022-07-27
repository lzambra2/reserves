require 'test_helper'

class Settings::CourseSubjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @settings_course_subject = settings_course_subjects(:one)
  end

  test 'should get index' do
    get settings_course_subjects_url
    assert_response :success
  end

  test 'should get new' do
    get new_settings_course_subject_url
    assert_response :success
  end

  test 'should create settings_course_subject' do
    assert_difference('Settings::CourseSubject.count') do
      post settings_course_subjects_url, params: { settings_course_subject: {} }
    end

    assert_redirected_to settings_course_subject_url(Settings::CourseSubject.last)
  end

  test 'should show settings_course_subject' do
    get settings_course_subject_url(@settings_course_subject)
    assert_response :success
  end

  test 'should get edit' do
    get edit_settings_course_subject_url(@settings_course_subject)
    assert_response :success
  end

  test 'should update settings_course_subject' do
    patch settings_course_subject_url(@settings_course_subject), params: { settings_course_subject: {} }
    assert_redirected_to settings_course_subject_url(@settings_course_subject)
  end

  test 'should destroy settings_course_subject' do
    assert_difference('Settings::CourseSubject.count', -1) do
      delete settings_course_subject_url(@settings_course_subject)
    end

    assert_redirected_to settings_course_subjects_url
  end
end
