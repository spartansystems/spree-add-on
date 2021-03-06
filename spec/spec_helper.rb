# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "simplecov"
SimpleCov.start "rails" do
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Models", "app/models"
  add_group "Views", "app/views"
  add_group "Libraries", "lib"
end

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require "rspec/rails"
require "database_cleaner"
require "ffaker"
require "factory_girl"
require "capybara/rspec"
require "shoulda/matchers"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

# Requires factories defined in spree_core
require "spree/testing_support/controller_requests"
require "spree/testing_support/authorization_helpers"
require "spree/testing_support/url_helpers"
require "spree/testing_support/factories"
require "spree/testing_support/preferences"

require "spree/api/testing_support/caching"
require "spree/api/testing_support/helpers"
require "spree/api/testing_support/setup"
# Find any extension definitions.
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Spree::Api::TestingSupport::Helpers, type: :controller
  config.extend Spree::Api::TestingSupport::Setup, type: :controller
  config.include Spree::TestingSupport::Preferences, type: :controller
  config.infer_spec_type_from_file_location!
  config.before do
    Spree::Api::Config[:requires_authentication] = true
  end

  # == URL Helpers
  #
  # Allows access to Spree"s routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::TestingSupport::UrlHelpers

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Capybara javascript drivers require transactional fixtures set to false,
  # and we use DatabaseCleaner to cleanup after each test instead.  Without
  # transactional fixtures set to false the records created to setup a test will
  # be unavailable to the browser, which runs under a seperate server instance.
  config.use_transactional_fixtures = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Disable the old "should" syntax in favor of the "expect" syntax.
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Ensure Suite is set to use transactions for speed.
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  # Before each spec check if it is a Javascript test and switch between using
  # database transactions or not where necessary.
  config.before :each do
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  # After each spec clean the database.
  config.after :each do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
