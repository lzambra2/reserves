# frozen_string_literal: true

require 'test_helper'

module Settings
  class CourseSubjectsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user, admin: true, role: User::MANAGER_ROLE)
      log_user_in(@user)
      @settings_course_subject = create(:courses_subject)
    end

    test 'should get index' do
      get settings_subjects_url
      assert_response :success
    end

    test 'should get new' do
      get new_settings_subject_url
      assert_response :success
    end

    test 'should create settings_course_subject and return to index' do
      assert_difference('Courses::Subject.count') do
        post settings_subjects_url,
             params: { courses_subject: { name: @settings_course_subject.name, code: @settings_course_subject.code } }
      end

      assert_redirected_to settings_subjects_path
    end

    test 'should show settings_course_subject' do
      get settings_subjects_path
      assert_response :success
    end

    test 'should get edit' do
      get edit_settings_subject_url(@settings_course_subject)
      assert_response :success
    end

    test 'should update settings_course_subject and return to index' do
      patch settings_subject_url(@settings_course_subject),
            params: { courses_subject: { name: @settings_course_subject.name, code: @settings_course_subject.code } }
      assert_redirected_to settings_subjects_path
    end

    test 'should destroy settings_course_subject' do
      assert_difference('Courses::Subject.count', -1) do
        delete settings_subject_url(@settings_course_subject)
      end

      assert_redirected_to settings_subjects_url
    end
  end
end
