class Signpost
  class Builder
    class Nested < self
      attr_reader :builders

      ##
      # Add middleware to routes
      #
      # Params:
      # - middleware {String|Class} middleware or middleware name
      # - *args                     middleware arguments which will be used for instantiating
      #
      # Example:
      #
      #     use Rack::Errors
      #     use AuthMiddleware, 'admin', 'seCrEt'
      #
      def use(middleware, *args, &block)
        @options[:middlewares] << Middleware.new(middleware, args, block)
      end

      def build
        Router.new(@builders, @options)
      end

    private

      def root_name
        nil
      end

    end
  end
end
