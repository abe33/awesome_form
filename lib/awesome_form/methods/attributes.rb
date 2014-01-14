module AwesomeForm
  module Methods
    module Attributes

    protected

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
end
