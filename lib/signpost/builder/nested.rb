class Signpost
  class Builder
    class Nested

      def expose(_router, routing_table, named_routes)
        subrouter = @builder.build
        subroutes = subrouter.routes

        named_routes.merge!(subrouter.named_routes)

        subroutes.keys.reject { |m| subroutes[m].empty? }.each do |method|
          routing_table[method] << Route::Nested.new(@subpath, subrouter)
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
