class Signpost
  class Builder
    class Plain

      class Path < self
        def to(spec)
          @to = spec
          self
        end

        def as(name)
          @name = name
          self
        end

        def except(condition)
          @except = condition
          self
        end

        def capture(constraints)
          @capture = constraints
          self
        end

        def params(params)
          @params = params
          self
        end

      private

        def get_matcher
          matcher_opts = {
            type: @options[:style] || :sinatra
          }

          matcher_opts[:capture] = @capture if @capture
          matcher_opts[:except]  = @except  if @except

          Mustermann.new(@pattern, matcher_opts)
        end

        def build_stack
          resolved = Endpoint::Resolver.new(@to, @options).resolve

          @endpoint_params = resolved.params

          Endpoint::Builder.new(resolved.endpoint, @options[:middlewares] || []).build
        end

        def build_params
          @endpoint_params.merge(@params)
        end
      end

    end
  end
end
