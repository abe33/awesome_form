require 'awesome_form/attributes_methods'
require 'awesome_form/inputs_methods'
module AwesomeForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    include AwesomeForm::AttributesMethods
    include AwesomeForm::InputsMethods

    def initialize(*)
      super
    end


    def actions(*args, &block)
      actions, options = filter_arguments(*args)

      actions.map {|f| input f, options }.join("\n").html_safe
    end

    def action(action, options={}, &block)
      render_options = {
        partial: "awesome_form/inputs/default",
        layout: nil,
        locals: {
          action: action,
          options: options,
        },
      }
      render render_options
    end

    def render(render_options)
      @template.render(render_options)
    end

    def view_exists?(view)
      path_elements = view.split('/')
      view = "_#{path_elements.pop}"
      prefix = path_elements.join('/')

      @template.lookup_context.exists? view, [prefix]
    end

  protected

    def model_name
      object.class.name.underscore.pluralize
    end

    def filter_arguments(*args)
      options = {}

      symbols = args.select {|a| a.is_a? Symbol }
      options_args = args.select {|a| a.is_a? Hash }
      options_args.each {|h| options.merge! h }

      [symbols, options]
    end

  end
end