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
Capybara.ignore_hidden_elements = false

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

root = Rails.root

RSpec.configure do |config|

  config.fixture_path = "#{root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.infer_base_class_for_anonymous_controllers = false

  config.order = "random"

  config.before(:all) do
    AwesomeForm.theme = :default_theme
  end

end
