class Signpost
  class Sign

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
        @options = options
        @builder = builder.new(builder_options, &block)
      end

      def builder
        Builder::Nested
      end

      def builder_options
        @options.merge({
          subroute:    @subpath,
          middlewares: @middlewares
        })
      end

    end

  end
end
