class Signpost
  class Builder
    class Simple

      class Path < self

        ##
        # Route endpoint specification
        # Might be a string, hash or class wich defines controller and action
        # names. Rack-compatible block is also acceptable.
        #
        # Params:
        # - spec {String|Hash|Class|Proc} endpoint spec
        #
        # Examples:
        #
        #     get('/').to('admin/users#index')
        #     get('/').to('Admin::Users#index')
        #     get('/').to(controller: 'Admin::Users', action: 'index')
        #     get('/').to(Admin::Users::List)
        #     get('/').to do |env|
        #       [200, {}, ['Hello world!']]
        #     end
        #
        def to(spec=nil, &block)
          @to = spec || block
          self
        end

        ##
        # Define named route
        #
        # Params:
        # - name {String|Symbol} route name
        #
        def as(name)
          @name = name
          self
        end

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

        ##
        # Define domain constraints for the route
        #
        # Params:
        # - constraints {Array}
        #
        # Examples:
        #
        #     get('/stats').constraint(->(env) { env['RACK_ENV'] == 'development' })
        #
        def constraint(*constraints)
          @constraints = constraints
          self
        end
        alias :constraints :constraint

        ##
        # Define default or additional params
        #
        # Params:
        # - params {Hash}
        #
        # Examples:
        #
        #     get('/pages/:id').params(id: 1)
        #     match('/:controller/:action').params(from: :dynamic_route)
        #
        def params(params)
          @params = params
          self
        end

      private

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

        def build_stack
          resolved = Endpoint::Resolver.new(@to || @block, @options).resolve

          @endpoint_params = resolved.params

          Endpoint::Builder.new(resolved.endpoint, @options[:middlewares] || []).build
        end

        def build_params
          @endpoint_params.merge(@params)
        end
      end

      Signpost::SUPPORTED_METHODS.each do |meth|
        class_eval <<-BUILD, __FILE__, __LINE__
      class #{meth} < Path
        def http_methods
          Set['#{meth}']
        end
      end
        BUILD
      end

      class Any < Path
        def via(*methods)
          @http_methods = methods.map { |m| m.to_s.upcase }.keep_if { |m| Signpost::SUPPORTED_METHODS.include?(m) }.to_set
        end

        def http_methods
          @http_methods || Signpost::SUPPORTED_METHODS
        end
      end

    end
  end
end
