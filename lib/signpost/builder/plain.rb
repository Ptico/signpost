class Signpost
  class Builder
    class Plain

      def build
        Route.new(get_matcher, build_stack, build_params, @constraints, @name)
      end

    private

      def initialize(pattern, options, &block)
        @pattern = pattern
        @options = options

        @params = {}
        @endpoint_params = {}
        @constraints = []

        @block = block
      end
    end
  end
end