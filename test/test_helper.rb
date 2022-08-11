ENV['RAILS_ENV'] = 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'shoulda/matchers'
include ActionDispatch::TestProcess

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper
end

class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  Devise::Test::IntegrationHelpers
  Warden.test_mode!

  def log_user_in(user)
    get login_url, headers: { 'HTTP_PYORK_USER' => user.uid }
  end

  def get_instance_var(what)
    controller.instance_variable_get("@#{what}")
  rescue NameError => e
    nil
  end

  def assert_template(which); end
end
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
