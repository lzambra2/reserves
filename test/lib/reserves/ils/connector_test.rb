require 'test_helper'

class Reserves::Ils::ConnectorTest < ActiveSupport::TestCase
  # should "throw a run time error if instantiating connector on its own" do
  #   assert_raises RuntimeError do
  #     Reserves::Ils::Connector.new
  #   end
  # end
  #
  # should "return a connector when calling get_instance " do
  #   assert_not_nil Reserves::Ils::Connector.get_instance("Reserves::Ils::DummyConnector")
  #
  #   i = Reserves::Ils::Connector.get_instance("Reserves::Ils::DummyConnector")
  #   assert_equal "Reserves::Ils::DummyConnector", i.class.name
  #
  #   i = Reserves::Ils::Connector.get_instance(nil)
  #   assert_equal "Reserves::Ils::DummyConnector", i.class.name
  # end
  #
  #
  # should "return true when calling a create_reserve on dummy connector" do
  #   connector = Reserves::Ils::Connector.get_instance("Reserves::Ils::DummyConnector")
  #   assert_equal true, connector.reserve_an_item(1, "Scott","HIST_1020", 22 )
  # end
end
