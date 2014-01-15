module AwesomeForm
  module Methods
    module Inputs

      def inputs(*args, &block)
        attributes, options = filter_arguments(*args)

        attributes = discover_attributes(object) if attributes.empty?

        attributes.map {|f| input f, options }.join("\n").html_safe
      end

      def input(attribute, options={}, &block)
        input_options = options_for_input(attribute, options)

        render_options = {
          partial: partial_for_input(input_options),
          layout: wrapper_for_input(input_options),
          locals: input_options,
        }

        render render_options
      end

    protected

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
