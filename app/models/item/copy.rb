class Item::Copy
  def copy_items(from_request, to_request)
    if (from_request && to_request) && Request::OPEN_STATUSES.include?(to_request.status)
      from_request.items.active.each do |i|
        new_item = i.dup
        new_item.request_id = to_request.id
        new_item.status = Item::STATUS_NOT_READY # reset status
        new_item.save
      end
    end
  end
end
