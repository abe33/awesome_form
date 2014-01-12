module AwesomeForm
  module DOM
    class DomExpression
      def initialize(source, test)
        @source = source
        @test = test
        @expressions = []

        parse
      end

      def match(elements)
        @expressions.each do |exp|
          elements.should @test.have_selector exp
        end
      end

      def parse
        current_indent = nil
        current = nil

        selector_stack = [nil]

        @source.split("\n").each_with_index do |line, i|
          expression = line.strip
          next if expression.empty?

          indent = line_indent line
          current_indent ||= indent

          if indent == current_indent
            selector_stack[-1] = expression

          elsif indent == current_indent + 1

            selector_stack << expression
            current_indent = indent

          elsif indent < current_indent and indent.round == indent
            dif = current_indent - indent
            selector_stack[(-1-dif.abs)..-1] = expression
            current_indent = indent
          else
            invalid_indent i
          end

          @expressions << selector_stack.join(' ')
        end
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
