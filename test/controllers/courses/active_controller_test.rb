# frozen_string_literal: true

require 'test_helper'

module Courses
  class ActiveControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user, admin: true, role: User::MANAGER_ROLE)
      log_user_in(@user)
      @course_active = create(:course)
    end

    test 'should get index' do
      get courses_active_index_url
      assert_response :success
    end

    test 'should show courses active' do
      get courses_active_url(@course_active)
      assert_response :success
    end

    test 'Download Excel file for active courses' do
      get courses_active_index_url, as: :xlsx
      assert_response :success
    end
  end
end
