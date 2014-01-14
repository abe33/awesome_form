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

  mattr_accessor :default_actions
  @@default_actions = [:submit]

  mattr_accessor :excluded_columns
  @@excluded_columns = [:created_at, :updated_at]

  mattr_accessor :default_associations
  @@default_associations = [:belongs_to, :has_many]

  def self.setup
    yield self
  end
end

