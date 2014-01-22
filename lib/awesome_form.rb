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

  mattr_accessor :default_input_class
  @@default_input_class = 'input'

  mattr_accessor :default_inputs_class
  @@default_inputs_class = 'inputs'

  mattr_accessor :default_label_class
  @@default_label_class = 'label'

  mattr_accessor :default_action_class
  @@default_action_class = 'action'

  mattr_accessor :default_actions_class
  @@default_actions_class = 'actions'

  mattr_accessor :default_input_wrapper_class
  @@default_input_wrapper_class = 'field'

  mattr_accessor :default_input_wrapper_error_class
  @@default_input_wrapper_error_class = 'has-errors'

    mattr_accessor :default_error_class
  @@default_error_class = 'inline-error'

  mattr_accessor :legal_attributes
  @@legal_attributes = {
    input: %w(accept alt autocomplete autofocus checked dirname disabled form formaction formenctype formmethod formnovalidate formtarget height list max maxlength min multiple name pattern placeholder readonly required size src step type value width).map(&:to_sym),
    textarea: %w(autocomplete autofocus cols dirname disabled form maxlength name placeholder readonly required rows wrap).map(&:to_sym),
    select: %w(autofocus disabled form multiple name required size).map(&:to_sym)
  }

  def self.setup
    yield self
  end
end

