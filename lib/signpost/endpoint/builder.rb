class Signpost
  class Endpoint
    class Builder

      ##
      # Build middleware stack
      #
      # Returns: {Proc}
      #
      def build
        @middlewares.reverse_each.inject(@endpoint) { |app, m| m.middleware.new(app, *m.args, &m.block) }
      end

    private

      def initialize(endpoint, middlewares)
        @endpoint    = endpoint
        @middlewares = middlewares
      end
    end
  end
end
