module AwesomeForm
  module Methods
    module Naming

      def input_name(attribute_name)
        "#{object_name}[#{attribute_name}]"
      end

      def collection_name(attribute_name, index=nil)
        "#{object_name}[#{attribute_name}][#{index}]"
      end

      def association_name(attribute_name)
        reflection = association_for_attribute(attribute_name)

        case reflection.macro
        when :belongs_to then input_name "#{attribute_name}_id"
        when :has_many then collection_name "#{attribute_name.to_s.singularize}_ids"
        when :has_one
          raise "Can't create the association name for a :has_one association"
        else
          raise "Unknown association #{reflection.macro}"
        end
      end

      def input_id(attribute_name)
        "#{object_name.underscore}_#{attribute_name}_input"
      end

    end
  end
end
