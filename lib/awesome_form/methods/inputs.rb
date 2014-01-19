require 'awesome_form/methods/rendering'

module AwesomeForm
  module Methods
    module Inputs
      extend AwesomeForm::Methods::Rendering

      render_method :input

    protected

      def default_keys_for_inputs
        discover_attributes(object)
      end

      def options_for_input(attribute, options)
        type_options = type_options_for_attribute attribute, options

        {
          attribute_name: attribute,
          object_name: object_name,
          object: object,
          builder: self,
        }
        .merge(type_options)
        .merge(options)
      end

      def default_inputs_content(options)
        content = ''
        content << "<legend>#{options[:legend]}</legend>" if options[:legend].present?
        content
      end

      def partial_for_input(input_options)
        lookup_views partial_paths_for_input(input_options)
      end

      def wrapper_for_input(input_options)
        partial_paths_for_input(input_options, :wrappers).select { |p| view_exists? p }.first
      end

      def partial_paths_for_input(input_options, scope=:inputs)
        theme = AwesomeForm.theme

        [
          "awesome_form/#{scope}/#{model_name}/#{input_options[:attribute_name]}",
          "awesome_form/#{theme}/#{scope}/#{model_name}/#{input_options[:attribute_name]}",

          "awesome_form/#{scope}/#{input_options[:type]}",
          "awesome_form/#{theme}/#{scope}/#{input_options[:type]}",
          "awesome_form/default_theme/#{scope}/#{input_options[:type]}",

          "awesome_form/#{scope}/default",
          "awesome_form/#{theme}/#{scope}/default",
          "awesome_form/default_theme/#{scope}/default"
        ].uniq
      end
    end
  end
end
