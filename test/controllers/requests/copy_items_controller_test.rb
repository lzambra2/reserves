require 'test_helper'

class Requests::CopyItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    @to_request = create(:request, requester: @user)

    log_user_in(@user)
  end

  ### SHOW ###
  should 'show the form to copy items from request to request' do
    other_requests = create_list(:request, 3, requester: @user)

    get request_copy_items_path(@to_request), xhr: true
    assert_response :success
    user_requests = get_instance_var(:user_requests)
    assert_not_nil user_requests
    assert_equal other_requests.size, user_requests.size, 'Should be same and not include the from request'
  end

  ### NEW ####

  should 'only load active items' do
    r = create(:request)
    i = create_list(:item, 2, request: r, status: Item::STATUS_NOT_READY)
    i_del = create_list(:item, 3, request: r, status: Item::STATUS_DELETED)

    get new_request_copy_items_path(@to_request), xhr: true, params: { custom_id: r.id }
    items = get_instance_var(:items)
    assert_equal i.size, items.size
    assert_equal items.first.status, Item::STATUS_NOT_READY
  end

  should 'load request and items if custom id is specified' do
    r = create(:request)
    i = create_list(:item, 2, request: r)

    get new_request_copy_items_path(@to_request), xhr: true, params: { custom_id: r.id }
    items = get_instance_var(:items)
    from_request = get_instance_var(:from_request)
    assert_not_nil items
    assert_not_nil from_request

    assert_equal i.size, items.size, 'Should load items'
  end

  should 'load request and items if request is part of user requests' do
    r = create(:request, requester: @user)
    i = create_list(:item, 2, request: r)

    get new_request_copy_items_path(@to_request), xhr: true, params: { from_request_id: r.id }
    items = get_instance_var(:items)
    from_request = get_instance_var(:from_request)
    assert_not_nil items
    assert_not_nil from_request

    assert_equal i.size, items.size, 'Should load items'
  end

  should 'not load request and items if request is not part of user requests' do
    r = create(:request)
    i = create_list(:item, 2, request: r)

    get new_request_copy_items_path(@to_request), xhr: true, params: { from_request_id: r.id }

    items = get_instance_var(:items)
    from_request = get_instance_var(:from_request)
    assert_nil from_request
    assert_not_nil items

    assert_equal 0, items.size, 'Should be no items'
  end

  ### CREATE ###
  should 'copy the items from request ' do
    r = create(:request)
    i = create_list(:item, 2, request: r, status: Item::STATUS_READY)

    assert_equal 0, @to_request.items.size

    post request_copy_items_path(@to_request), params: { from_request_id: r.id }
    request = get_instance_var(:request)
    assert_equal i.size, request.items.size
    assert_redirected_to request_path(request)
  end
end
