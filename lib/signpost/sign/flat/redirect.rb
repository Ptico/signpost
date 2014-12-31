class Signpost
  class Sign
    class Flat

      class Redirect < self

        def to(path_or_name=nil, additional_values=nil, &block)
          if block_given?
            @to = block
          else
            @to = path_or_name
            @additional = additional_values if additional_values
          end

          self
        end

        def permanent
          @status = 301
          self
        end

        def temporary
          @status = 303
          self
        end

        def with_status(status)
          @status = status
          self
        end

      private

        def initialize(*)
          super
          @status = @options[:default_redirect_status]
          @additional = @options[:default_redirect_additional_values] || :ignore
        end

        def build_stack(router)
          to_opts = { additional_values: @additional }
          to = @to.is_a?(String) ? Mustermann::Expander.new(@to, to_opts) : @to

          endpoint = Signpost::Endpoint::Redirect.new(to || @block, router, @status)
        end

        def build_params
          @endpoint_params
        end

        def http_methods
          Signpost::SUPPORTED_METHODS
        end

      end

    end
  end
end
