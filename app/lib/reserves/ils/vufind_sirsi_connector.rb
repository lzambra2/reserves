module Reserves
  module Ils
    class VufindSirsiConnector < Connector
      def initialize(vufind_url)
        @vufind_url = vufind_url
      end
    end
  end
end
