module AwesomeForm
  class FormBuilder < ActionView::Helpers::FormBuilder

    def initialize(*)
      super
    end

    def inputs(*args, &block)
      attributes, options = filter_arguments(*args)

      attributes.map {|f| input f, options }.join("\n").html_safe
    end

    def input(attribute, options={}, &block)
      input_options = input_options_for_attribute(attribute, options)

      render_options = {
        partial: partial_for_input(input_options),
        layout: wrapper_for_input(input_options),
        locals: { options: options }.merge(input_options),
      }

      render render_options
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

    def filter_arguments(*args)
      options = {}

      symbols = args.select {|a| a.is_a? Symbol }
      options_args = args.select {|a| a.is_a? Hash }
      options_args.each {|h| options.merge! h }

      [symbols, options]
    end

    def partial_for_input(input_options)
      for_type = "awesome_form/#{AwesomeForm.theme}/inputs/#{input_options[:type]}"
      default_for_theme = "awesome_form/#{AwesomeForm.theme}/inputs/default"

      if view_exists? for_type
        for_type
      elsif view_exists? default_for_theme
        default_for_theme
      else
        "awesome_form/default_theme/inputs/default"
      end
    end

    def wrapper_for_input(input_options)
    end

    def input_options_for_attribute(attribute, options)
      type_options = type_options_for_attribute attribute, options

      {
        attribute_name: attribute,
        object_name: object_name,
        object: object,
        builder: self,
      }.merge(type_options)
    end

    def type_options_for_attribute(attribute, options)
      type_options = {}
      type_options[:type] = options[:as].to_sym if options[:as].present?

      column = column_for_attribute attribute
      association = association_for_attribute attribute

      if column.present?
        type = column.type
        type_options[:column_type] = type

        type = type_for_string(attribute, column) if type == :string
        type_options[:type] ||= type

      elsif association.present?
        type_options[:type] ||= :association
        type_options[:association_type] = association.macro

      else
        type_options[:type] ||= type_for_string(attribute, options)
      end

      type_options
    end

    def type_for_string(attribute, column)
      case attribute.to_s
      when /password/ then :password
      when /time_zone/ then :time_zone
      when /country/ then :country
      when /email/ then :email
      when /phone/ then :tel
      when /url/ then :url
      else
        # file_method?(attribute_name) ? :file : (input_type || :string)
        :string
      end
    end

    def column_for_attribute(attribute)
      if @object.respond_to?(:column_for_attribute)
        @object.column_for_attribute(attribute)
      end
    end

    def association_for_attribute(attribute)
      if @object.class.respond_to?(:reflect_on_association)
        @object.class.reflect_on_association(attribute)
      end
    end
  end
end
