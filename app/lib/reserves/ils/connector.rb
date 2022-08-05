module Reserves
  module Ils
    class Connector
      def initialize
        raise 'Use Connector.get_ils_connector'
      end

      def self.get_instance(class_name)
        # returns new ILS connector
        if !class_name.nil?
          class_name.constantize.new
        else
          Reserves::Ils::DummyConnector.new
        end
      end

      def create_reserve(item_id, reserve_location); end

      def create_or_link_course(course_id, item_id); end

      def link_user(user_id, item_id); end

      ## Catch all, step by step method to reserve an item
      def reserve_an_item(item_id, reserve_location, course_id, user_id)
        create_reserve(item_id, reserve_location)
        create_or_link_course(course_id, user_id)
        link_user(user_id, item_id)
      end
    end
  end
end
