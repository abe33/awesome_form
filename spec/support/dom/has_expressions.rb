module AwesomeForm
  module DOM
    module HasExpressions

      def << (expression)
        expression.parent = self
        @expressions << expression
      end

    end
  end
end
