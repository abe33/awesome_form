require 'rubygems'

# Coveralls must be required first
require 'coveralls'
Coveralls.wear!

ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"
require "rspec/autorun"

require "aruba/api"

require "capybara/rails"
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

root = Rails.root

RSpec.configure do |config|

  config.fixture_path = "#{root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false

  config.order = "random"

end
