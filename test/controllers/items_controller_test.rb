require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @_request = create(:request, status: Request::INPROGRESS)

    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'list all items for request' do
    create(:item)
    create_list(:item, 3, request: @_request)

    get request_items_path(@_request)
    assert_response :success
    items = get_instance_var(:items)
    assert_equal 3, items.size, '3 Items'
  end

  should 'show new item form' do
    get new_request_item_path(@_request.id)
    assert_response :success
  end

  should 'create a new item' do
    assert_difference('Item.count') do
      post request_items_path(@_request), params: { item: attributes_for(:item).except(:request) }
      item = get_instance_var(:item)
      assert_equal 0, item.errors.size, "Should be no errors, #{item.errors.messages}"
      assert_redirected_to request_item_path(@_request, item)
    end
  end

  should 'send en email to location email, after item created, if enabled' do
    @_request.location.setting_bcc_location_on_new_item = true
    @_request.location.save

    assert_enqueued_emails 1 do
      post request_items_path(@_request), params: { item: attributes_for(:item).except(:request) }
    end
  end

  should 'show item details' do
    item = create(:item, request: @_request)

    get request_item_path(@_request, item)
    assert_response :success
  end

  should 'show edit form' do
    item = create(:item, request: @_request)

    get edit_request_item_path(@_request, item)
    assert_response :success
  end

  should 'update an existing item' do
    item = create(:item, request: @_request)
    old_title = item.title

    patch request_item_path(@_request, item), params: { item: { title: 'New Title' } }
    item = get_instance_var(:item)
    assert_equal 0, item.errors.size, 'Should be no errors'
    assert_response :redirect
    assert_redirected_to request_item_path(@_request, item)

    assert_not_equal old_title, item.title, 'Old title is not there'
    assert_equal 'New Title', item.title, 'Title was updated'
  end

  should 'destroy not item' do
    item = create(:item, request: @_request)

    assert_no_difference('Item.count') do
      delete request_item_path(@_request, item)
    end

    assert_redirected_to request_path(@_request)
  end

  ## ADDITIONAL ACTIONS TESTS ##

  should 'change request status to open if new item is added' do
    request = create(:request, status: Request::INPROGRESS)
    post request_items_path(@_request), params: { item: attributes_for(:item).except(:request) }
    r = get_instance_var(:request)
    assert_equal Request::OPEN, r.status, 'Status should be set to open'
  end

  should 'change status' do
    item = create(:item, status: Item::STATUS_NOT_READY, request: @_request)

    get change_status_request_item_path(@_request, item), params: { status: Item::STATUS_READY }
    assert_redirected_to @_request
    i = get_instance_var(:item)
    assert_equal Item::STATUS_READY, i.status, 'Status should change to ready'

    get change_status_request_item_path(@_request, item), params: { status: Item::STATUS_NOT_READY }
    i = get_instance_var(:item)
    assert_equal Item::STATUS_NOT_READY, i.status, 'Status should change to not ready'
  end

  should 'only change status to DELETED if request is REMOVED' do
    request = create(:request, status: Request::REMOVED)
    item = create(:item, request: request)

    get change_status_request_item_path(request, item), params: { status: Item::STATUS_DELETED }
    assert_redirected_to request, 'Should go back to request'
    i = get_instance_var(:item)
    assert_equal Item::STATUS_DELETED, i.status, 'Status should be changed to DELETED'

    [Request::COMPLETED, Request::OPEN, Request::INPROGRESS, Request::CANCELLED].each do |s|
      r = create(:request, status: s)
      i = create(:item, request: r)
      get change_status_request_item_path(r, i), params: { status: Item::STATUS_DELETED }
      _i = get_instance_var(:item)
      assert_not_equal Item::STATUS_DELETED, _i.status, 'Status should be be DELETED'
    end
  end

  should 'not be able to change DELETED status' do
    request = create(:request, status: Request::REMOVED)
    item = create(:item, request: request, status: Item::STATUS_DELETED)

    get change_status_request_item_path(request, item), params: { status: Item::STATUS_READY }
    i = get_instance_var(:item)
    assert_equal Item::STATUS_DELETED, i.status, 'Status should still be DELETED'
  end
end
