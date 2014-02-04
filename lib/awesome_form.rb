require 'action_view'
require "awesome_form/engine"
require "awesome_form/form_builder"
require "awesome_form/action_view_extensions/form_helper"

module AwesomeForm
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :FormBuilder
  end

  # Exposed configurations

  mattr_accessor :default_actions
  @@default_actions = %i(submit)

  mattr_accessor :excluded_columns
  @@excluded_columns = %i(created_at updated_at)

  mattr_accessor :default_associations
  @@default_associations = %i(belongs_to has_many)

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

  mattr_accessor :default_row_class
  @@default_row_class = 'row'

  mattr_accessor :default_column_class
  @@default_column_class = 'column'

  mattr_accessor :column_class_processor
  @@column_class_processor = Proc.new {|columns| "column-#{columns}" }

  mattr_accessor :default_error_class
  @@default_error_class = 'inline-error'

  # Restricted configurations

  mattr_accessor :theme
  @@theme = :default_theme

  def self.theme=(theme)
    theme = theme.to_sym
    if theme == :default_theme
      self.load_configuration default_options
    else
      self.load_configuration theme_configurations[theme] || self.config_struct.new
    end
  end

  mattr_accessor :mergeable_attributes
  @@mergeable_attributes = %i(class style)

  mattr_reader :legal_attributes
  @@legal_attributes = {
    global: %i(accesskey class contenteditable contextmenu dir draggable dropzone hidden id inert itemid itemprop itemref itemscope itemtype lang spellcheck style tabindex title translate),
    input: %i(accept alt autocomplete autofocus checked dirname disabled form formaction formenctype formmethod formnovalidate formtarget height list max maxlength min multiple name pattern placeholder readonly required size src step type value width),
    textarea: %i(autocomplete autofocus cols dirname disabled form maxlength name placeholder readonly required rows wrap),
    select: %i(autofocus disabled form multiple name required size),
    button: %i(autofocus disabled form formaction formenctype formmethod formnovalidate formtarget menu name type value),
    label: %i(form for),
  }

  def self.setup
    yield self
  end

  def self.register(name)
    config = self.config_struct.new
    yield config

    self.theme_configurations[name] = config
  end

protected

  mattr_reader :accessible_options
  @@accessible_options = %i(default_actions excluded_columns default_associations default_input_class default_inputs_class default_action_class default_actions_class default_label_class default_input_wrapper_class default_input_wrapper_error_class default_error_class default_row_class default_column_class mergeable_attributes)

  mattr_reader :config_struct
  @@config_struct = Struct.new(*self.accessible_options)

  mattr_accessor :default_options
  @@default_options = self.config_struct.new(*accessible_options.map {|k| self.send(k) })

  mattr_reader :theme_configurations
  @@theme_configurations = HashWithIndifferentAccess.new

  def self.load_configuration(conf)
    accessible_options.each do |k|
      value = conf.send(k)
      self.send("#{k}=", value) if value.present?
    end
  end

end

