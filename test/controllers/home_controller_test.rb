require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  context 'Staff' do
    setup do
      @user = create(:user, admin: true, role: User::MANAGER_ROLE)
      log_user_in(@user)
    end

    should 'display home dashboard with open requests by default' do
      create_list(:request, 2, status: Request::OPEN)
      get root_path

      which = get_instance_var(:which)
      assert_equal Request::OPEN, which, 'Should be open by default'

      assert_response :success
    end

    should 'show requests based on status' do
      create_list(:request, 2, status: Request::OPEN)
      create_list(:request, 3, status: Request::INPROGRESS)
      create_list(:request, 4, status: Request::CANCELLED, cancelled_date: 10.days.ago)
      create_list(:request, 5, status: Request::COMPLETED, completed_date: 10.days.ago)
      create_list(:request, 6, status: Request::UPCYCLED)
      create_list(:request, 7, status: Request::REMOVED)

      get root_path, params: { which: Request::INPROGRESS, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 3, requests.size, '3 In Progress'

      get root_path, params: { which: Request::COMPLETED, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 5, requests.size, '5 Completed'

      get root_path, params: { which: Request::CANCELLED, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 4, requests.size, '4 Cancelled'

      get root_path, params: { which: Request::UPCYCLED, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 6, requests.size, '6 UPCYCLED'

      get root_path, params: { which: Request::REMOVED, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 7, requests.size, '6 REMOVED'

      get root_path, params: { location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 2, requests.size, '2 Open'
    end

    should 'show requests paginated' do
      create_list(:request, 50, status: Request::OPEN)
      create_list(:request, 50, status: Request::INPROGRESS)

      get root_path, params: { which: Request::OPEN, page: 1, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 50, requests.size, '50 Per page'

      get root_path, params: { which: Request::INPROGRESS, page: 1, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 50, requests.size, '50 Per page'
    end

    should 'show only 30 day old Completed and 60 day old cancelled' do
      create_list(:request, 1, status: Request::CANCELLED, cancelled_date: 1.months.ago)
      create_list(:request, 2, status: Request::CANCELLED, cancelled_date: 3.months.ago)

      create_list(:request, 1, status: Request::COMPLETED, completed_date: 1.week.ago)
      create_list(:request, 2, status: Request::COMPLETED, completed_date: 2.months.ago)

      get root_path, params: { which: Request::COMPLETED, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 3, requests.size, 'Should only be 1 completed'

      get root_path, params: { which: Request::CANCELLED, location: 'all' }
      requests = get_instance_var(:requests)
      assert_equal 3, requests.size, 'Should only be 1 cancelled'
    end
  end

  context 'User' do
    setup do
      @user = create(:user, admin: false, user_type: User::FACULTY)
      log_user_in(@user)
    end

    should 'redirect to my requests' do
      get root_path
      assert_redirected_to requests_user_url(@user), 'Should redirect to my requests url for this user'
    end
  end
end
