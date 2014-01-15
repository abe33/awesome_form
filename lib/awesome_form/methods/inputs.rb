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

      def partial_for_input(input_options)
        paths = partial_paths_for_input(input_options)

        paths.select { |p| view_exists? p }.first
      end

      def partial_paths_for_input(input_options)
        theme = AwesomeForm.theme

        [
          "awesome_form/inputs/#{model_name}/#{input_options[:attribute_name]}",
          "awesome_form/#{theme}/inputs/#{model_name}/#{input_options[:attribute_name]}",

          "awesome_form/inputs/#{input_options[:type]}",
          "awesome_form/#{theme}/inputs/#{input_options[:type]}",
          "awesome_form/default_theme/inputs/#{input_options[:type]}",

          "awesome_form/inputs/default",
          "awesome_form/#{theme}/inputs/default",
          "awesome_form/default_theme/inputs/default"
        ].uniq
      end

      def wrapper_for_input(input_options)
        "awesome_form/default_theme/wrappers/default"
      end
    end
  end
end
