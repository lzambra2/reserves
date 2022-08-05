require 'test_helper'

class LocationsControllerTest < ActionDispatch::IntegrationTest
  context 'CRUD Controller Location Tests' do
    setup do
      @mylocation = create(:location)

      @user = create(:user, admin: true, role: User::MANAGER_ROLE, location: @mylocation)
      log_user_in(@user)
    end

    should 'list all locations' do
      create_list(:location, 10)

      get locations_path
      assert_response :success
      locations = get_instance_var(:locations)
      assert_equal 11, locations.size, '10 Locations + 1 from setup'
    end

    should 'show new location form' do
      get new_location_path

      assert_template :new
    end

    should 'create a new location' do
      assert_difference('Location.count') do
        post locations_path, params: { location: attributes_for(:location) }
        location = get_instance_var(:location)
        assert_equal 0, location.errors.size, 'Should be no errors'
        assert_redirected_to locations_path
      end
    end

    should 'show location details' do
      get location_path(@mylocation)
      assert_response :success
    end

    should 'show get edit form' do
      get edit_location_path(@mylocation)
      assert_response :success
    end

    should 'update an existing location' do
      old_location_name = @mylocation.name

      patch location_path(@mylocation), params: { location: { name: 'Scott Library' } }
      location = get_instance_var(:location)
      assert_equal 0, location.errors.size, 'Location name did not update'
      assert_response :redirect
      assert_redirected_to locations_path

      assert_not_equal old_location_name, location.name, 'Old location name is not there'
      assert_equal 'Scott Library', location.name, 'Location Name was updated'
    end

    should 'do not delete, only mark it as deleted location' do
      assert_difference('Location.count', 0, 'Location was deleted, it should only be marked deleted.') do
        delete location_path(@mylocation)
      end

      patch location_path(@mylocation), params: { location: { is_deleted: true } }
      location = get_instance_var(:location)
      assert_equal 0, location.errors.size, 'Location is_deleted did not update'
      assert_response :redirect
      assert_redirected_to locations_path

      assert_equal true, location.is_deleted, 'Location should have been marked deleted.'
    end

    ### SPECIFIC TESTS ###
    should 'update disallowed_item_types  field' do
      assert_equal 0, @mylocation.disallowed_item_types.size, 'Should be no disallowed types'

      patch location_path(@mylocation), params: { location: { disallowed_item_types: %w[book ebook] } }

      location = get_instance_var(:location)
      assert_equal 2, location.disallowed_item_types.size, 'Shoudl be 2 disallowed types'
    end
  end
end
