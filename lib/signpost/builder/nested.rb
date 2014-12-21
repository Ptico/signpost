class Signpost
  class Builder
    class Nested

      def expose(routing_table, named_routes)
        router = @builder.build
        routes = router.routes

        named_routes.merge!(router.named_routes)

        routes.keys.reject { |m| routes[m].empty? }.each do |method|
          routing_table[method] << Route::Nested.new(@subpath, router)
        end
      end

    private

      def initialize(subpath, options, &block)
        @subpath = subpath
        @options = options.merge({
          subroute: @subpath,
          nested: true,
          middlewares: options[:middlewares].dup
        })

        @builder = Builder.new(@options, &block)
      end

    end
  end
end
