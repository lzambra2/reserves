# frozen_string_literal: true

require 'test_helper'

class Item::CopyTest < ActiveSupport::TestCase
  setup do
    @from_request = create(:request)
    @from_items = create_list(:item, 3, request: @from_request, status: Item::STATUS_READY)
    @from_items_deleted = create_list(:item, 4, request: @from_request, status: Item::STATUS_DELETED)
    @item_copier = Item::Copy.new
  end

  should "not make a copy of items if requests don't exist" do
    assert_no_difference 'Item.count' do
      @item_copier.copy_items(nil, nil)
    end
  end

  should 'not make a copy of items if to_request is not Open or Impocmplete' do
    Request::CLOSED_STATUSES.each do |status|
      to_request = create(:request, status: status)
      assert_no_difference 'Item.count' do
        @item_copier.copy_items(@from_reuqest, to_request)
      end
    end
  end

  should 'make a copy from one request to the other' do
    to_request = create(:request, status: Request::OPEN)
    assert_difference 'Item.count', @from_items.size do
      @item_copier.copy_items(@from_request, to_request)
    end

    assert_equal @from_items.size, to_request.items.size, 'Should match'

    assert_equal @from_items.first.item_type, to_request.items.first.item_type, 'Item Types should match'
  end

  should 'only copy active items' do
    to_request = create(:request, status: Request::OPEN)

    @from_items.each do |i|
      assert_equal Item::STATUS_READY, i.status, 'Status IS READY by default'
    end

    assert_difference 'Item.count', @from_items.size do
      @item_copier.copy_items(@from_request, to_request)
    end

    assert_equal @from_items.size, to_request.items.size, 'Shoud match and not include deleted'

    to_request.items.each do |i|
      assert_equal Item::STATUS_NOT_READY, i.status, 'Status should be reset to NOT READY'
    end
  end
end
