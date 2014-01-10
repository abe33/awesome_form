module AwesomeForm
  module DOM
    module HasAncestors
      attr_accessor :parent

      def ancestors
        ancestors = [parent]
        ancestor = parent

        while ancestor
          ancestors << ancestor
          ancestor = ancestor.parent
        end

        ancestors
      end

      def nth_ancestor(index)
        ancestors[index]
      end

    end
  end
end
