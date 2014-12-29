class Signpost
  class Builder
    class Simple

      ##
      # Do not match given pattern
      #
      # Params:
      # - pattern {String} pattern to ignore
      #
      # Examples:
      #
      #     delete('/pages/:id').except('/pages/1')
      #     get('/pages/*slug/edit').except('/pages/system/*/edit')
      #
      def except(pattern)
        @except = pattern
        self
      end

      ##
      # Define pattern constraints for the route
      #
      # Params:
      # - constraints {Hash|Array|Symbol|RegExp|String}
      #
      # Examples:
      #
      #     get('/:id').capture(:digit)
      #     get('/:id').capture(/\d+/)
      #     get('/:id_or_slug').capture([/\d+/, :word])
      #     get('/:id.:ext').capture(id: /\d+/, ext: ['png', 'jpg'])
      #
      def capture(constraints)
        @capture = constraints
        self
      end

      def expose(router, routing_table, named_routes)
        route = Route::Simple.new(get_matcher, build_stack(router), build_params, @constraints, @name)
        named_routes[route.name.to_sym] = route if route.name

        http_methods.each do |method|
          routing_table[method] << route
        end
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

      ##
      # Private: Build Mustermann matcher from given pattern and options
      #
      def get_matcher
        matcher_opts = {
          type: @options[:style] || :sinatra
        }

        matcher_opts[:capture] = @capture if @capture
        matcher_opts[:except]  = @except  if @except

        Mustermann.new(@pattern, matcher_opts)
      end

    end
  end
end
