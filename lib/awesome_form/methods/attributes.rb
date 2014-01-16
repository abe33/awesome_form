module AwesomeForm
  module Methods
    module Attributes

      def discover_attributes(model)
        cols = association_columns(*AwesomeForm.default_associations)
        cols += content_columns
        cols -= AwesomeForm.excluded_columns
        cols.compact
      end

    protected

      def type_options_for_attribute(attribute, options)
        type_options = {}
        type_options[:type] = options.delete(:as).to_sym if options[:as].present?

        column = column_for_attribute attribute
        association = association_for_attribute attribute

        if column.present?
          type_options.reverse_merge! column_options_for(column)
        elsif association.present?
          type_options.reverse_merge! association_options_for(association)
        else
          type_options[:type] ||= type_for_string(attribute)
        end

        type_options.merge options
      end

      def type_for_string(attribute)
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

      def column_options_for(column)
        type = column.type

        column_options = {
          column_type: type,
          type: type == :string ? type_for_string(column.name) : type
        }

        column_options
      end

      def association_options_for(association)
        association_options = {
          type: :association,
          association_type: association.macro,
          multiple: association.instance_variable_get(:@collection),
          collection: association.klass.all.map do |rec|
            [ rec.try(:id), rec.try(:name) || rec.try(:to_s) ]
          end
        }

        if association_options[:multiple]
          association_options[:selected] = object.send(association.name).map(&:id)
        else
          association_options[:selected] = object.send(association.name) ? [object.send(association.name).try(:id)] : []
        end

        association_options
      end

      def content_columns()
        klass = object.class
        return [] unless klass.respond_to?(:content_columns)
        klass.content_columns.collect { |c| c.name.to_sym }.compact
      end

      def association_columns(*by_associations)
        if object.present? && object.class.respond_to?(:reflections)
          object.class.reflections.collect do |name, association_reflection|
            if by_associations.present?
              if by_associations.include?(association_reflection.macro) && association_reflection.options[:polymorphic] != true
                name
              end
            else
              name
            end
          end.compact
        else
          []
        end
      end
    end
  end
end
