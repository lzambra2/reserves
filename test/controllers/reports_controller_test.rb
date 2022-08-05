require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  context 'Reports | Requests' do
    should 'show requests by location' do
      create_list(:request, 2, reserve_location_id: 1)
      create(:request, reserve_location_id: 2)

      get requests_reports_path, params: { r: { location: 1 } }
      list = get_instance_var(:requests)
      assert_equal 2, list.size, 'Should be two'

      get requests_reports_path
      list = get_instance_var(:requests)
      assert_equal 3, list.size, 'Should be all of them'
    end

    should 'show requests by department' do
      course = create(:course, code: '2015_ES_ADMB_F_50510__1_A')
      create_list(:request, 3, course: course)
      create(:request)

      get requests_reports_path, params: { r: { department: 'ADMB' } }
      list = get_instance_var(:requests)
      assert_equal 3, list.size, 'Should be 3'

      get requests_reports_path
      list = get_instance_var(:requests)
      assert_equal 4, list.size, 'Should be all of them'
    end

    should 'show requests that are expiring' do
      create_list(:request, 3, reserve_end_date: 2.weeks.from_now, status: Request::COMPLETED)
      create_list(:request, 2, reserve_end_date: 2.weeks.from_now, status: Request::REMOVED)
      create(:request, reserve_end_date: 1.month.from_now, status: Request::COMPLETED)

      get requests_reports_path, params: { r: { expiring_before: 3.weeks.from_now } }
      list = get_instance_var(:requests)
      assert_equal 3, list.size, 'Should be 3, not 5, the REMOVED should not be counted'

      get requests_reports_path, params: { r: { expiring_before: 6.weeks.from_now } }
      list = get_instance_var(:requests)
      assert_equal 4, list.size, 'Should be 4, not 6, the REMOVED should not be counted'

      get requests_reports_path
      list = get_instance_var(:requests)
      assert_equal 6, list.size, "Should be all, since we didn't provide any expiration date"
    end

    should 'show requests that have been created between date ranges' do
      create_list(:request, 2, created_at: 2.weeks.ago)
      create_list(:request, 3, created_at: 3.months.ago)

      get requests_reports_path, params: { r: { created_before: 1.week.from_now, created_after: 3.weeks.ago } }
      list = get_instance_var(:requests)
      assert_equal 2, list.size, 'Should be 2'

      get requests_reports_path, params: { r: { created_before: 3.weeks.ago, created_after: 4.months.ago } }
      list = get_instance_var(:requests)
      assert_equal 3, list.size, 'Should be 3'
    end

    should 'produce proper result, given all request parameters' do
      ### UPDATE THIS IF NEW PARAMETERS ARE ADDED
      course = create(:course, code: '2015_ES_ADMB_F_50510__1_A')
      create_list(:request, 3, course: course, reserve_location_id: 1, status: Request::COMPLETED,
                               reserve_end_date: 2.weeks.from_now, created_at: 1.week.ago)
      create_list(:request, 2, created_at: 3.months.ago, reserve_location_id: 10)

      get requests_reports_path,
          params: { r: { expiring_before: 2.weeks.from_now, created_before: 1.week.from_now, created_after: 2.weeks.ago,
                         location: 1, department: 'ADMB' } }
      list = get_instance_var(:requests)
      assert_equal 3, list.size, 'Should be 3 matching all of these criteria'
    end
  end

  context 'Reports | Requests' do
    setup do
      @course = create(:course, code: '2015_ES_ADMB_F_50510__1_A')
      @request_good = create(:request, reserve_location_id: 1, course: @course)
      @request_other = create(:request, reserve_location_id: 3999)
    end

    should 'show items by location' do
      create_list(:item, 2, request: @request_good)
      create(:item, request: @request_other)

      get items_reports_path, params: { r: { location: @request_good.reserve_location_id } }
      list = get_instance_var(:items)
      assert_equal 2, list.size, 'Should be two'

      get items_reports_path
      list = get_instance_var(:items)
      assert_equal 3, list.size, 'Should be all of them'
    end

    should 'show items by department' do
      create_list(:item, 3, request: @request_good)
      create(:item, request: @request_other)

      get items_reports_path, params: { r: { department: @course.subject } }
      list = get_instance_var(:items)
      assert_equal 3, list.size, 'Should be 3'

      get items_reports_path, params: {}
      list = get_instance_var(:items)
      assert_equal 4, list.size, 'Should be all of them'
    end

    should 'show items that have been created between date ranges' do
      create_list(:item, 2, created_at: 2.weeks.ago)
      create_list(:item, 3, created_at: 3.months.ago)

      get items_reports_path, params: { r: { created_before: 1.week.from_now, created_after: 3.weeks.ago } }
      list = get_instance_var(:items)
      assert_equal 2, list.size, 'Should be 2'

      get items_reports_path, params: { r: { created_before: 3.weeks.ago, created_after: 4.months.ago } }
      list = get_instance_var(:items)
      assert_equal 3, list.size, 'Should be 3'
    end

    should 'show items by Item Type' do
      create_list(:item, 2, item_type: Item::TYPE_BOOK)
      create_list(:item, 3, item_type: Item::TYPE_EBOOK)

      get items_reports_path, params: { r: { item_types: Item::TYPE_BOOK } }
      list = get_instance_var(:items)
      assert_equal 2, list.size, 'Should be 2'

      get items_reports_path, params: { r: { item_types: Item::TYPE_EBOOK } }
      list = get_instance_var(:items)
      assert_equal 3, list.size, 'Should be 3'
    end

    should 'produce proper result, given all items parameters' do
      ### UPDATE THIS IF NEW PARAMETERS ARE ADDED
      create_list(:item, 3, request: @request_good, item_type: Item::TYPE_BOOK, created_at: 1.week.ago)
      create_list(:item, 2, request: @request_other, item_type: Item::TYPE_EBOOK, created_at: 3.months.ago)

      get items_reports_path,
          params: { r: { item_types: Item::TYPE_BOOK, created_before: 1.week.from_now, created_after: 2.weeks.ago,
                         location: @request_good.reserve_location_id, department: @course.subject } }
      list = get_instance_var(:items)
      assert_equal 3, list.size, 'Should be 3 matching all of these criteria'
    end
  end
end
