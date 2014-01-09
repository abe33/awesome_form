require 'action_view'
require "awesome_form/engine"
require "awesome_form/action_view_extensions/form_helper"

module AwesomeForm
  extend ActiveSupport::Autoload

  autoload :Helpers

  def self.setup
    yield self
  end
end

