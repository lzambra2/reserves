# frozen_string_literal: true

require 'test_helper'

class AcquisitionRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'list  acquisition items by status' do
    create_list(:acquisition_request, 3, status: nil)
    create_list(:acquisition_request, 4, status: AcquisitionRequest::STATUS_ACQUIRED, acquired_at: Time.now)
    create_list(:acquisition_request, 2, status: AcquisitionRequest::STATUS_CANCELLED, cancelled_at: Time.now)

    get acquisition_requests_path
    assert_response :success
    items = get_instance_var(:acquisition_requests)
    assert_equal 3, items.size, '3 Open acquisition requests'
  end

  should 'show acquisition_request details' do
    @acquisition_request = create(:acquisition_request)

    get acquisition_request_path(@acquisition_request)
    assert_response :success
  end

  ### CREATING ###

  should 'show new acquistion request' do
    item = create(:item)
    get new_acquisition_request_path, params: { item_id: item.id }
    assert_response :success

    assert get_instance_var(:item), 'Should load an request for which to create an acquisition'
  end

  should 'create a new acquisition request' do
    item = create(:item)
    assert_difference('AcquisitionRequest.count') do
      ai = build(:acquisition_request, item: item)
      post acquisition_requests_path, params: { acquisition_request: ai.attributes }

      request = get_instance_var(:acquisition_request)
      assert_equal item.request.reserve_location, request.location, 'Locations should match'
      assert_equal 0, request.errors.size, "Should be no errors, #{request.errors.messages}"
      assert_redirected_to acquisition_request_path(request)
    end
  end

  ### EDITING ###

  should 'show edit form' do
    @acquisition_request = create(:acquisition_request)

    get edit_acquisition_request_path(@acquisition_request)
    assert_response :success
  end

  should 'update an existing acquisition_request' do
    @acquisition_request = create(:acquisition_request)
    old_source_type = @acquisition_request.acquisition_source_type

    patch acquisition_request_path(@acquisition_request),
          params: { acquisition_request: { acquisition_source_type: 'NEW' } }
    acquisition_request = get_instance_var(:acquisition_request)
    assert_equal 0, acquisition_request.errors.size, "Should be no errors, #{acquisition_request.errors.messages}"
    assert_response :redirect
    assert_redirected_to acquisition_request_path(acquisition_request)

    assert_not_equal old_source_type, acquisition_request.acquisition_source_type, 'Old source type is not there'
    assert_equal 'NEW', acquisition_request.acquisition_source_type, 'Source Type was updated'
  end

  should 'destroy an existing acquisition item' do
    @acquisition_request = create(:acquisition_request)

    assert_difference('AcquisitionRequest.count', -1) do
      delete acquisition_request_path(@acquisition_request)
    end

    assert_redirected_to acquisition_requests_path
  end

  ### STATUS CHANGES ###
  should "set status to #{AcquisitionRequest::STATUS_ACQUIRED}" do
    @arequest = create(:acquisition_request)
    source_type = 'Publisher'
    source_name = 'Penguin'

    patch change_status_acquisition_request_path(@arequest), params: { status: AcquisitionRequest::STATUS_ACQUIRED,
                                                                       acquisition_request: {
                                                                         acquisition_source_type: source_type, acquisition_source_name: source_name
                                                                       } }

    acquisition_request = get_instance_var(:acquisition_request)
    assert_response :redirect
    assert_redirected_to acquisition_request_path(acquisition_request)

    assert acquisition_request, 'Request was loaded'
    assert_equal AcquisitionRequest::STATUS_ACQUIRED, acquisition_request.status, 'Status should be acquired'
    assert_equal source_type, acquisition_request.acquisition_source_type
    assert_equal source_name, acquisition_request.acquisition_source_name

    assert_equal @user.id, acquisition_request.acquired_by.id, 'Records who acquired it'
    assert_not_nil acquisition_request.acquired_at, 'Date and time acquired should set'
    assert_equal Date.today, acquisition_request.acquired_at.to_date, 'Should be today'
  end

  should "set status to #{AcquisitionRequest::STATUS_CANCELLED}" do
    @arequest = create(:acquisition_request)
    reason = 'Duplicate'

    patch change_status_acquisition_request_path(@arequest), params: { status: AcquisitionRequest::STATUS_CANCELLED,
                                                                       acquisition_request: { cancellation_reason: reason } }

    acquisition_request = get_instance_var(:acquisition_request)
    assert_response :redirect
    assert_redirected_to acquisition_request_path(acquisition_request)

    assert acquisition_request, 'Request was loaded'
    assert_equal AcquisitionRequest::STATUS_CANCELLED, acquisition_request.status, 'Status should be cancelled'
    assert_equal reason, acquisition_request.cancellation_reason

    assert_equal @user.id, acquisition_request.cancelled_by.id, 'Records who cancelled it'
    assert_not_nil acquisition_request.cancelled_at, 'Date and time cancelled should set'
    assert_equal Date.today, acquisition_request.cancelled_at.to_date, 'Should be today'
  end

  ## SENDING ACQUISITION'S EMAIL ##
  should 'send acquisition email to bookstore' do
    arequest = create(:acquisition_request)

    assert_enqueued_emails 1 do
      post send_to_acquisitions_acquisition_request_path(arequest),
           params: { which: AcquisitionRequest::EMAIL_TO_BOOKSTORE }
    end

    assert_redirected_to acquisition_request_path(arequest)
  end

  should "send acquisition email to acquisition's department" do
    arequest = create(:acquisition_request)

    assert_enqueued_emails 1 do
      post send_to_acquisitions_acquisition_request_path(arequest),
           params: { which: AcquisitionRequest::EMAIL_TO_ACQUISITIONS }
    end

    assert_redirected_to acquisition_request_path(arequest)
  end

  should "send acquisition email to location's acquisition email address" do
    location = create(:location, acquisitions_email: 'some@test.com')
    arequest = create(:acquisition_request, location: location)

    assert_enqueued_emails 1 do
      post send_to_acquisitions_acquisition_request_path(arequest),
           params: { which: AcquisitionRequest::EMAIL_TO_LOCATION }
    end

    assert_redirected_to acquisition_request_path(arequest)
  end

  ## AUTHORIZATION ##
  should 'be able to see acquisition requests from my own and other locations' do
    location = create(:location)
    user = create(:user,  admin: true, role: User::STAFF_ROLE, location: location)

    ar_same_loc = create(:acquisition_request, location: location)
    ar_diff_loc = create(:acquisition_request, location: create(:location))

    ability = Ability.new(user, {})

    assert ability.can?(:read, ar_same_loc), 'Should be able to first acquisition request'
    assert ability.can?(:show, ar_same_loc), 'Should be able to show acquisition request'
    assert ability.can?(:update, ar_same_loc), 'Should be able to read update acquisition request'
    assert ability.can?(:change_status, ar_same_loc), 'Should be able tochange_status acquisition request'

    assert ability.can?(:read, ar_diff_loc), 'Should be able to read  acquisition request'
    assert ability.can?(:show, ar_diff_loc), 'Should be able to  show acquisition request'
    assert ability.can?(:update, ar_diff_loc), 'Should be able to  update acquisition request'
    assert ability.can?(:change_status, ar_diff_loc), 'Should be able to change_status acquisition request'

    assert ability.cannot?(:send_to_acquisitions, ar_diff_loc), 'Should not be able to send to acquisitions'
    assert ability.cannot?(:send_to_acquisitions, ar_same_loc), 'Should not be able to send to acquisitions'
  end
end
