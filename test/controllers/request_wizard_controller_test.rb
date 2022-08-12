# frozen_string_literal: true

require 'test_helper'

class RequestWizardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = create(:location)
    @course = create(:course)

    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'show new request form - STEP ONE' do
    get new_request_step_one_path
    assert_response :success

    assert get_instance_var(:request)
  end

  should 'create the request from step one and move onto step two (set status to INCOMPLETE)' do
    assert_difference('Request.count') do
      request_attributes = attributes_for(:request, reserve_location_id: @location.id)
      request_attributes[:course_attributes] = attributes_for(:course)
      request_attributes[:user] = { office: '1234 building', department: 'Department of sorts', phone: '1232312312321' }

      post new_request_step_one_save_path, params: { request: request_attributes }
      request = get_instance_var(:request)
      assert_equal 0, request.errors.size, "Should be no errors, #{request.errors.messages.inspect}"
      assert_equal Request::INCOMPLETE, request.status, 'Status should be set to INCOMPLETE'
      assert_redirected_to new_request_step_two_path(request), 'Should redirect to Step Two'
      assert_equal @user.id, request.requester.id, 'Requester id was set'
    end
  end

  should 'load the request and any items, if comping back to this' do
    request = create(:request, status: Request::INCOMPLETE)

    get new_request_step_two_path(request)
    assert_response :success

    assert get_instance_var(:items)
    assert get_instance_var(:request)
  end

  test 'should finialize request (change status to OPEN) if there is at least one item attached' do
    request = create(:request, status: Request::INCOMPLETE)

    post new_request_finish_path(request)
    r = get_instance_var(:request)
    assert_equal Request::INCOMPLETE, r.status, 'Status should still be incomplete'
    assert_response :redirect
    assert_redirected_to new_request_step_two_path(request),
                         'Should redirect to Step Two since there are no items attached'

    create(:item, request: request)

    assert_enqueued_emails 1 do
      post new_request_finish_path(request)
    end
    r = get_instance_var(:request)
    assert_equal Request::OPEN, r.status, 'Status should now be OPEN'

    assert_response :redirect
    assert_redirected_to request_path(request), 'Show request details'
  end
end
