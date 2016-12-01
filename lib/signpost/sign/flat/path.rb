class Signpost
  class Sign
    class Flat

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
        def as(name, postfix=nil)
          namespace_name = @namespace ? Inflecto.underscore(@namespace.to_s.tr('::', '')) : nil
          @name = (postfix ? [name, namespace_name, postfix] : [namespace_name, name]).flatten.compact.join('_')
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

        def build_stack(router, matcher)
          if @block && @block.arity == 0
            @to = Endpoint::Action.new(@block, router)
          end

          matches = matcher.names
          resolver = Resolver.new(@to || @block, @options[:namespace], @options[:controller_format])

          if matches.include?('controller') || matches.include?('action')
            @endpoint_params = resolver.preresolve # TODO - Should be updated after resolving
            endpoint = Endpoint::Dynamic.new(@options, @endpoint_params)
          else
            resolved = resolver.resolve
            endpoint = resolved.endpoint
            @endpoint_params = resolved.params
          end

          Endpoint::Builder.new(endpoint, @options[:middlewares] || []).build
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
