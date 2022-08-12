# frozen_string_literal: true

require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  should 'should create valid Request using defaults from factory girl' do
    request = build(:request)

    assert_difference 'Request.count', 1 do
      request.save
    end
  end

  context 'Request Validation' do
    should validate_presence_of(:reserve_start_date).with_message('Cannot be empty')
    should validate_presence_of(:reserve_end_date).with_message('Cannot be empty')
    should validate_presence_of(:reserve_location_id).with_message('Cannot be empty')
    should validate_presence_of(:course).with_message('Cannot be empty')

    # Special Requirements #
  end

  should 'ensure requester_email is a valid email' do
    assert !build(:request, requester_email: 'dfjlasdjfasl, dlfjasld').valid?, 'Not valid at all'
    assert !build(:request, requester_email: 'test@test.com, yes@yes.com').valid?, 'Not valid at all'

    assert build(:request, requester_email: 'yazoo_city@mississipi.com').valid?, 'Should be valid'
  end

  should 'show by status scope' do
    open = create_list(:request, 2, status: Request::OPEN)
    completed = create_list(:request, 1, status: Request::COMPLETED)
    inprogress = create_list(:request, 3, status: Request::INPROGRESS)
    cancelled = create_list(:request, 5, status: Request::CANCELLED)
    incomplete = create_list(:request, 1, status: Request::INCOMPLETE)
    upcycled = create_list(:request, 4, status: Request::UPCYCLED)

    assert_equal open.size, Request.open.size
    assert_equal completed.size, Request.completed.size
    assert_equal inprogress.size, Request.in_progress.size
    assert_equal cancelled.size, Request.cancelled.size
    assert_equal incomplete.size, Request.incomplete.size
    assert_equal upcycled.size, Request.upcycled.size

    assert_equal open.size + completed.size + inprogress.size + upcycled.size, Request.visible.size
  end

  should 'show expiring soon requests with status COMPLETE' do
    create_list(:request, 2, reserve_end_date: 1.week.from_now, status: Request::COMPLETED)
    create_list(:request, 3, reserve_end_date: 1.week.from_now, status: Request::REMOVED)

    assert_equal 2, Request.expiring_soon.size, 'Should be 2'
  end

  should 'show requests based on reserve end date' do
    create_list(:request, 2, reserve_end_date: 1.week.from_now, status: Request::COMPLETED)
    create_list(:request, 3, reserve_end_date: 2.weeks.from_now, status: Request::COMPLETED)
    create_list(:request, 4, reserve_end_date: 5.weeks.from_now, status: Request::COMPLETED)

    Setting.request_expiry_notice_interval = 1.weeks
    # puts "Setting 1: #{Request.expiring_soon.to_sql}"
    assert_equal 2, Request.expiring_soon.size, 'Should be 2'

    Setting.request_expiry_notice_interval = 2.weeks
    # puts "Setting 2: #{Request.expiring_soon.to_sql}"
    assert_equal 5, Request.expiring_soon.size, 'Should be 5'

    # Change the expiriy settings
    Setting.request_expiry_notice_interval = 4.weeks
    # puts "Setting 3: #{Request.expiring_soon.to_sql}"
    expire_date = (DateTime.now.beginning_of_day + 5.weeks)
    assert_equal 9, Request.expiring_soon(expire_date).size, 'Should be 9'
  end

  should 'rollover request with items' do
    r = create(:request) # with items
    create_list(:item, 3, request_id: r.id)

    request = r.rollover

    assert_equal Request::OPEN, request.status, 'Status should be OPEN'
    assert_equal r.requester_id, request.requester_id
    assert_equal r.reserve_location_id, request.reserve_location_id
    assert r.requester_email == request.requester_email
    assert_equal Date.today, request.requested_date

    assert_equal r.items.size, request.items.size, 'number of items match'
    assert_not_equal r.course.id, request.course.id, 'Course ID shoudl be different'

    # ensure rollover parent and date are recorded
    assert_equal request.rollover_parent_id, r.id, 'Should be rollover parent'
    assert_not_nil request.rolledover_at, 'Should be set'
    assert_equal DateTime.now.beginning_of_day.strftime('%m/%d/%Y'),
                 request.rolledover_at.beginning_of_day.strftime('%m/%d/%Y'), 'Should match the day '

    ## assert original request is UPCYCLED
    r.reload
    assert_equal r.status, Request::UPCYCLED, "Original request should have it's status changed to UPCYCLED"
  end

  should 'rollover request, only active items' do
    r = create(:request) # with items
    items = create_list(:item, 3, request_id: r.id)
    deleted_item = items.first.update(status: Item::STATUS_DELETED)

    request = r.rollover

    assert_equal Request::OPEN, request.status, 'Status should be OPEN'
    assert_equal 2, request.items.size
  end

  should 'rollover request and set year' do
    c = create(:course, year: '2014')
    r = create(:request, course: c)

    request = r.rollover('2015')
    assert_equal '2015', request.course.year, 'Years should match'
  end

  should "mass archive all completed requests whos reserve_end_date is #{Setting.request_archive_all_after} days old" do
    not_expired = create_list(:request, 2, status: Request::OPEN)
    completed_expired = create_list(:request, 3, status: Request::COMPLETED,
                                                 reserve_end_date: Date.today - Setting.request_archive_all_after.to_i)

    removed = Request.mass_archive(1, true)
    assert_equal completed_expired.size, removed.size, 'should be teh same number'
    removed.each do |r|
      assert_equal Request::REMOVED, r.status
      assert_equal 1, r.removed_by_id
      assert_not_nil r.removed_at
    end
  end

  should "mass remove incomplete requests that are older than ate in seetings if remove flag is set to true, don't otherwise" do
    open_requests = create_list(:request, 2, status: Request::OPEN)
    incomplete_old = create_list(:request, 3, status: Request::INCOMPLETE, created_at: 2.years.ago)
    incomplete_current = create_list(:request, 5, status: Request::INCOMPLETE, created_at: 1.month.ago)

    assert_equal open_requests.size + incomplete_old.size + incomplete_current.size, Request.all.size

    assert_no_difference 'Request.count', 'Should not remove any because remove flag was not set' do
      removed = Request.remove_incomplete(false)
    end

    Setting.request_remove_incomplete_after = 1.year

    assert_difference 'Request.count', -incomplete_old.size do
      removed = Request.remove_incomplete(true)
      assert_equal incomplete_old.size, removed.size
    end

    assert_equal open_requests.size + incomplete_current.size, Request.all.size
  end
end
