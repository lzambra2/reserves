require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # Relationship Tests
  # should have_many(:departments) i.e. Location Scott Library has many departments AND Each department should only belong to one location.

  should 'should create valid Location using defaults from factory girl' do
    location = build(:location)

    assert_difference 'Location.count', 1 do
      location.save
    end
  end

  context 'Location Validation' do
    should validate_presence_of(:name).with_message('Cannot be empty')
    should_not allow_value('test@test').for(:contact_email).with_message('Invalid email format.')

    # Special Requirements #

    should 'store disallowed' do
      location = create(:location, disallowed_item_types: [Item::TYPE_BOOK, Item::TYPE_MAP])

      assert_equal 2, location.disallowed_item_types.size, 'There should be two disallowed item types'
    end
  end

  should 'show active and inactive locations' do
    create_list(:location, 2, is_deleted: true)
    create_list(:location, 3, is_deleted: false)

    assert_equal 3, Location.active.size, '3 active'
    assert_equal 2, Location.inactive.size, '2 inactive'
  end
end
