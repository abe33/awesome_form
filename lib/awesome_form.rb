require 'action_view'
require "awesome_form/engine"
require "awesome_form/form_builder"
require "awesome_form/action_view_extensions/form_helper"

module AwesomeForm
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :FormBuilder
  end

  mattr_accessor :theme
  @@theme = :default_theme

  def self.setup
    yield self
  end
end

