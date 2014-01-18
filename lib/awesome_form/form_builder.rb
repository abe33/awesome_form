require 'awesome_form/methods/attributes'
require 'awesome_form/methods/inputs'
require 'awesome_form/methods/actions'
require 'awesome_form/methods/naming'
require 'awesome_form/methods/labels'

module AwesomeForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    include AwesomeForm::Methods::Attributes
    include AwesomeForm::Methods::Inputs
    include AwesomeForm::Methods::Actions
    include AwesomeForm::Methods::Naming
    include AwesomeForm::Methods::Labels

    def initialize(*)
      super
    end

    def render(render_options)
      @template.render(render_options)
    end

    def view_exists?(view)
      path_elements = view.split('/')
      view = "_#{path_elements.pop}".squeeze '_'
      prefix = path_elements.join('/')

      @template.lookup_context.exists? view, [prefix]
    end

    def lookup_views(paths)
      paths.select { |p| view_exists? p }.first
    end

    def filter_attributes_for(html, options)
      options.select do |k|
        AwesomeForm.legal_attributes[html].include?(k) ||
        k.to_s =~ /^data($|-)/
      end
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
