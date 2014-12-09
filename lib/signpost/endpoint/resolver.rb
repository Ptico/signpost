class Signpost
  class Endpoint
    UnresolvedError = Class.new(StandardError)

    class Resolver
      ##
      # Class: result of resolving
      #
      # Here is `#endpoint` is an endpoint class and `#params` is a hash
      # with controller and action names
      #
      Result = Struct.new(:endpoint, :params)

      ##
      # Resolve endpoint and params
      #
      # Returns: {Signpost::Endpoint::Resolver::Result}
      #
      def resolve
        case spec
          when Proc
            endpoint = spec
            params   = {}
          when Hash
            params = resolve_hash(spec[:controller], spec[:action])
          when String
            params = resolve_string
        end

        unless endpoint
          endpoint = params[:action].kind_of?(Class) ? params[:action] : params[:controller]
        end

        Result.new(endpoint, params)
      end

    private

      attr_reader :spec, :options

      ##
      # Constructor:
      #
      # Params:
      # - spec {String|Hash|Proc}
      # - options {Hash}
      #   - :namespace         {String} namespace
      #   - :controller_format {String} string with controller name pattern
      #
      def initialize(spec, options={})
        @spec = spec
        @options = options
      end

      ##
      # Private: resolve controller and action
      #
      # Params:
      # - controller {String|Class} controller name or constant
      # - action     {String}       action name
      #
      # Returns: {Hash}
      # - :controller {Module|Class} controller constant
      # - :action     {String|Class} action name or constant
      #
      def resolve_hash(controller, action)
        fail(NameError) if controller.nil? # FIXME workaround for https://github.com/mbj/inflecto/issues/6

        if controller.kind_of?(Module)
          if action
            pattern = "#{controller}::#{Inflecto.camelize(action)}"
            action = Inflecto.constantize(pattern) if Object.const_defined?(pattern)
          end
        else
          name = controller_name(controller)

          return resolve_hash(Inflecto.constantize(Inflecto.camelize(name)), action)
        end

        { controller: controller, action: action }
      rescue NameError
        raise(UnresolvedError)
      end

      ##
      # Private: resolve controller and action from string
      #
      # Returns: {Hash}
      # - :controller {Module|Class} controller constant
      # - :action     {String|Class} action name or constant
      #
      def resolve_string
        controller, action = spec.split('#')

        resolve_hash(controller, action)
      end

      ##
      # Private: get controller name from pattern and namespace
      #
      # Params:
      # - controller {String} raw controller name
      #
      # Returns: {String} namespaced controller name from pattern
      #
      def controller_name(controller)
        names = {
          name:          controller,
          plural_name:   Inflecto.pluralize(controller),
          singular_name: Inflecto.singularize(controller)
        }

        pattern = options[:controller_format] || '%{name}'

        name = pattern % names
        name = "#{options[:namespace]}::#{name}" if options[:namespace]

        name
      end
    end
  end
end