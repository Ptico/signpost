class Signpost
  class Builder
    class Simple

      def expose(routing_table, named_routes)
        route = build
        named_routes[route.name] = route if route.name

        http_methods.each do |method|
          routing_table[method] << route
        end
      end

      def build
        Route::Simple.new(get_matcher, build_stack, build_params, @constraints, @name)
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
