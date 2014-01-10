Dir[File.expand_path("../*.rb", __FILE__)].each { |f| require f }

module AwesomeForm
  module DOM
    class NodeExpression
      include AwesomeForm::DOM::HasExpressions
      include AwesomeForm::DOM::HasAncestors

      def initialize(expression)
        @expression = expression
        @expressions = []
      end

      def match(elements)
        if is_text_expression?
          match_content_of elements
        else
          match_selector_of elements
        end
      end

      def is_text_expression?
        @expression =~ /^(\/|'|").*(\/|'|")$/
      end

      def match_content_of(elements)
        elements.has_content?(@expression)
      end

      def match_selector_of(elements)

        elements = elements.respond_to?(:all) ? elements.all(@expression) : elements.find(@expression)

        p @expression
        p elements

        children_matches = @expressions.all? {|ex| ex.match elements }
        elements.present? && (@expressions.empty? || children_matches)
      end

    end
  end
end
