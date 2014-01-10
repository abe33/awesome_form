Dir[File.expand_path("../*.rb", __FILE__)].each { |f| require f }

module AwesomeForm
  module DOM
    class DomExpression
      include AwesomeForm::DOM::HasExpressions

      attr_accessor :parent

      def initialize(source)
        @source = source
        @expressions = []

        parse
      end

      def match(elements)
        @expressions.all? {|ex| ex.match elements }
      end

      def parse
        starting_indent = 0
        current_parent = self
        current_indent = nil
        current = nil

        @source.split("\n").each_with_index do |line, i|
          expression = line.strip
          next if expression.empty?

          indent = line_indent line
          current_indent ||= indent

          node_expression = AwesomeForm::DOM::NodeExpression.new expression

          if indent == current_indent
            current_parent << node_expression
            current = node_expression

          elsif indent == current_indent + 1
            text_expression_has_no_child i if current.is_text_expression?

            current << node_expression
            current_indent = indent
            current_parent = current
            current = node_expression

          elsif indent < current_indent and indent.round == indent
            dif = current_indent - indent
            current_parent = current.nth_ancestor dif.abs
            current_parent << node_expression
            current_indent = indent
            current = node_expression
          else
            invalid_indent i
          end

        end
      end

      def text_expression_has_no_child(line)
        raise "text expressions cannot have children on line #{ line + 1 }"
      end

      def invalid_indent(line)
        raise "invalid indent on line #{ line + 1 } of '#{ @source }'"
      end


      def line_indent(line)
        res = line.split(/[^ ]/)[0]

        res ? res.size / 2 : 0
      end
    end
  end
end
