# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true, role: User::MANAGER_ROLE)
    log_user_in(@user)
  end

  should 'search by id' do
    r = create(:request)

    get search_path, params: { q: r.id }

    requests = get_instance_var(:requests)
    assert requests, 'Requests should not be nil'
    assert_equal 1, requests.size, 'Only one'
    assert_equal r.id, requests.first.id, 'Matching'
  end

  # should "search by instructor name or course title" do
  #   c = create(:course, instructor: "John Terry", name: "Football Tacticts")
  #   r = create(:request, course: c)
  #   create_list(:request, 3)
  #
  #    get search_path, params: {  q: "John" }
  #
  #   requests = get_instance_var(:requests)
  #   assert requests
  #   assert requests.size >= 1, "At least one match should be"
  #
  #   get search_path, params: { q: "Football" }
  #   requests = get_instance_var(:requests)
  #   assert requests
  #   assert requests.size >- 1, "at least one match"
  #
  #
  # end
  #
  # should "return an empty array if nothing is found" do
  #   get search_path, params: { q: "searching emptiness" }
  #
  #   requests = get_instance_var(:requests)
  #   assert requests
  #   assert_equal 0, requests.size, "Should be nothing there"
  # end

  should 'return an request if found an item with specified id. Using [i: 2323] pattern' do
    i = create(:item)
    r = i.request

    get search_path, params: { q: "i: #{i.id}" }

    requests = get_instance_var(:requests)
    assert requests
    assert_equal 1, requests.size, 'Should be one only'
    assert_equal requests.first.id, r.id, 'Request ids are matched'
  end
end
