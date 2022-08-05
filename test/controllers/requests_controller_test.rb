require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  context 'CRUD Tests' do
    setup do
      @user = create(:user, admin: true, role: User::MANAGER_ROLE)
      log_user_in(@user)
    end

    should 'list all requests' do
      create_list(:request, 10)

      get requests_path
      assert_response :success
      requests = get_instance_var(:requests)
      assert_equal 10, requests.size, '10 Courses'
    end

    should 'show request details' do
      request = create(:request)

      get request_path(request)
      assert_response :success

      admins = get_instance_var(:admin_users)
      assert_not_nil admins
      assert_equal 1, admins.size, 'Current user should be there'
    end

    should 'show get edit form' do
      request = create(:request)

      get edit_request_path(request)
      assert_response :success
    end

    should 'update an existing request' do
      request = create(:request)

      old_request_reserve_start_date = request.reserve_start_date
      user_attributes = { office: '1234 building', department: 'Department of sorts', phone: '1232312312321' }

      patch request_path(request), params: { request: { reserve_start_date: '2014-09-15', user: user_attributes } }
      r = get_instance_var(:request)
      assert_equal 0, r.errors.size, 'Request did not update reserve_start_date'
      assert_response :redirect
      assert_redirected_to request_path(r)

      assert_not_equal old_request_reserve_start_date, r.reserve_start_date, 'Old reserve start date is not there'
      assert_equal '2014-09-15', r.reserve_start_date.strftime('%Y-%m-%d'), 'Reserve date was updated'
    end

    should 'destroy request' do
      request = create(:request)

      assert_difference('Request.count', -1) do
        delete request_path(request)
      end

      assert_redirected_to requests_path
    end

    ## ADDITIONAL ACTIONS TESTS ##

    should 'change status' do
      request = create(:request, status: Request::OPEN, requester_email: 'someone@something.com')
      Setting.email_allow = true

      assert_no_enqueued_emails do
        get change_status_request_path(request), params: { status: Request::INPROGRESS }
      end

      assert_redirected_to request_path(request)

      r = get_instance_var(:request)
      assert_equal Request::INPROGRESS, r.status

      assert_enqueued_emails 1 do
        get change_status_request_path(request), params: { status: Request::COMPLETED }
      end

      r = get_instance_var(:request)
      assert_equal Request::COMPLETED, r.status
      assert_equal Date.today, r.completed_date, 'Completed Date should be set'

      request = create(:request, status: Request::OPEN)

      assert_no_enqueued_emails do
        get change_status_request_path(request), params: { status: Request::CANCELLED }
      end
      r = get_instance_var(:request)
      assert_equal Request::CANCELLED, r.status
      assert_equal Date.today, r.cancelled_date, 'Cancelled date should be set'
    end

    should 'be able to re-open request if cancelled or completed' do
      request = create(:request, status: Request::COMPLETED)

      get change_status_request_path(request), params: { status: Request::OPEN }
      r = get_instance_var(:request)
      assert_equal Request::OPEN, r.status, 'Should be open after being completed'

      request.update(status: Request::CANCELLED)

      get change_status_request_path(request), params: { status: Request::OPEN }
      r = get_instance_var(:request)
      assert_equal Request::OPEN, r.status, 'Should be open after being cancelled'
    end

    should 'not be able to cancel completed request or complete a cancelled on' do
      request = create(:request, status: Request::COMPLETED)

      get change_status_request_path(request), params: { status: Request::CANCELLED }
      r = get_instance_var(:request)
      assert_equal Request::COMPLETED, r.status, 'Nothing has changed'

      request.update(status: Request::CANCELLED)
      get change_status_request_path(request), params: { status: Request::COMPLETED }
      r = get_instance_var(:request)
      assert_equal Request::CANCELLED, r.status, 'Request remains cancelled'
    end

    should 'assign request to the user that clicked on start' do
      request = create(:request, status: Request::OPEN)

      get change_status_request_path(request), params: { status: Request::INPROGRESS }
      r = get_instance_var(:request)
      assert_equal @user.id, r.assigned_to.id, 'Request should be assigned to the user'
    end

    should 'assign request to the nil / no one if re-opened' do
      request = create(:request, status: Request::COMPLETED, assigned_to: @user)

      get change_status_request_path(request), params: { status: Request::OPEN }
      r = get_instance_var(:request)
      assert_nil r.assigned_to, 'Request should be assigned to nil'
    end

    should 'be able to roll over the request and redirect to edit new request page' do
      request = create(:request, status: Request::COMPLETED)
      post rollover_request_path(request)
      new_request = get_instance_var(:new_request)
      assert_redirected_to edit_request_path(new_request), 'Should redirect to edit page'
    end

    should 'be able to archive the request' do
      request = create(:request, status: Request::COMPLETED)

      get change_status_request_path(request), params: { status: Request::REMOVED }
      r = get_instance_var(:request)
      assert_equal Request::REMOVED, r.status
      assert_equal Date.today.beginning_of_day, r.removed_at.beginning_of_day, 'Archived at is recorded'
      assert_equal @user.id, r.removed_by_id, 'Current user is recored as having to have archvied the request'
    end

    should 'be able to change requester on a request' do
      request = create(:request, status: Request::OPEN)
      user = create(:user)
      old_id = request.requester_id

      patch change_owner_request_path(request), params: { requester_id: user.id }
      r = get_instance_var(:request)
      assert_equal r.requester_id, user.id, 'Owner Changed'
      assert_redirected_to request_path(r), 'Should redirect to request path'
    end
  end

  context 'As regular user' do
    setup do
      @other_request = create(:request)
      @user = create(:user, role: User::INSTRUCTOR_ROLE)
      log_user_in(@user)
    end

    should 'be able to destroy own requests that are INCOMPLETE' do
      request = create(:request, requester: @user, status: Request::INCOMPLETE)

      assert_difference('Request.count', -1) do
        delete request_path(request)
      end

      r2 = create(:request, requester: @user, status: Request::OPEN)
      assert_no_difference 'Request.count' do
        delete request_path(r2)
      end
    end

    should "not be able to destroy other's request" do
      assert_no_difference 'Request.count' do
        delete request_path(@other_request)
      end
    end
  end
end
