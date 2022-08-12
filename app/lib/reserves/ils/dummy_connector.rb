# frozen_string_literal: true

module Reserves
  module Ils
    class DummyConnector < Connector
      def initialize; end

      def reserve_an_item(_item_id, _reserve_location, _course_id, _user_id)
        true
      end
    end
  end
end
