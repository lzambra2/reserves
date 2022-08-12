# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'show settings form' do
    get edit_settings_path
    assert_response :success
  end

  should 'update settings upon submission' do
    Setting.app_name = 'test'

    assert_equal 'test', Setting.app_name, 'Precondition, name is test'

    put settings_path, params: { setting: { app_name: 'reserves' } }

    assert_equal 'reserves', Setting.app_name, 'Should have saved a new name'
    assert_redirected_to edit_settings_path, 'Should go back to the form'
  end

  should 'redirect to proper page' do
    put settings_path, params: { setting: { app_name: 'reserves' }, return_to: 'item_request' }
    assert_redirected_to item_request_settings_path

    put settings_path, params: { setting: { app_name: 'reserves' }, return_to: 'cat_search' }
    assert_redirected_to cat_search_settings_path

    put settings_path, params: { setting: { app_name: 'reserves' }, return_to: 'email' }
    assert_redirected_to email_settings_path

    put settings_path, params: { setting: { app_name: 'reserves' }, return_to: 'acquisition_requests' }
    assert_redirected_to acquisition_requests_settings_path

    put settings_path, params: { setting: { app_name: 'reserves' }, return_to: 'general' }
    assert_redirected_to edit_settings_path
  end
end
